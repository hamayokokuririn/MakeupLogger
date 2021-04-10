//
//  FaceAnnotationRepository.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import UIKit

protocol MakeupLogRepository {
    func getLogList(completion: ([MakeupLog]) -> Void)
    func insertMakeupLog(title: String, body: String?, image: UIImage, completion: (MakeupLog?) -> Void)
    func updateFacePart(logID: MakeupLog.ID, part: FacePart, completion: (MakeupLog?) -> Void)
    func insertFacePart(logID: MakeupLog.ID, type: String, image: UIImage, completion: (MakeupLog?) -> Void)
    func updateFaceAnnotation(logID: MakeupLog.ID, partID: FacePart.ID, faceAnnotation: FaceAnnotation, completion: (MakeupLog?) -> Void)
    func insertFaceAnnotation(logID: MakeupLog.ID, partID: FacePart.ID, completion: (MakeupLog?) -> Void)
    
    var logMap: [MakeupLog.ID: MakeupLog] { get }
}

class MakeupLogRepositoryInMemory: MakeupLogRepository {
    static let shared = MakeupLogRepositoryInMemory()
    
    let id = MakeupLog.ID(idNumber: 1)
    lazy var log: MakeupLog = MakeupLog(id: id,
                                        title: "makeup_sample", image: #imageLiteral(resourceName: "sample_face"),
                                        partsList: [eye])
    lazy var eye: FacePart = { FacePart(id: FacePart.ID(idNumber: 1), type: "eye", image: #imageLiteral(resourceName: "sample_eye_line"),
                                        annotations: [eyeAnnotation])}()
    
    let faceID = FaceAnnotation.FAID(id: 1)
    let colorID = ColorPalletAnnotation.CPID(id: 1)
    lazy var eyeAnnotation: FaceAnnotation = { FaceAnnotation(id: faceID,
                                                              text: "1",
                                                              pointRatioOnImage: PointRatio(x: 0.1, y: 0.2),
                                                              comment: Comment(text: "暗めにする"),
                                                              colorPallet: colorPallet,
                                                              selectedColorPalletAnnotationID: colorID)}()
    
    let colorID1 = ColorPalletAnnotation.CPID(id: 1)
    let colorID2 = ColorPalletAnnotation.CPID(id: 2)
    let colorID3 = ColorPalletAnnotation.CPID(id: 3)
    lazy var colorPalletAnnotation1 = ColorPalletAnnotation(id: colorID1,
                                                            text: "1",
                                                            pointRatioOnImage: PointRatio(x: 0, y: 0))
    lazy var colorPalletAnnotation2 = ColorPalletAnnotation(id: colorID2,
                                                            text: "2",
                                                            pointRatioOnImage: PointRatio(x: 0.3, y: 0))
    lazy var colorPalletAnnotation3 = ColorPalletAnnotation(id: colorID3,
                                                            text: "3",
                                                            pointRatioOnImage: PointRatio(x: 0.6, y: 0))
    lazy var colorPallet = ColorPallet(id: ColorPallet.ColorPalletID(idNumber: 0),
                                       title: "color_pallet",
                                       image: UIImage(named: "sample_color_pallet"),
                                       annotationList: [colorPalletAnnotation1,
                                                        colorPalletAnnotation2,
                                                        colorPalletAnnotation3])
    
    lazy var logMap = [id: log]
    
    private var logList: [MakeupLog] {
        logMap.values.map {$0 as MakeupLog}
    }
    
    private init() {}
    
    func setLog(logMap: [MakeupLog.ID: MakeupLog]? = nil) {
        if let map = logMap {
            self.logMap = map
            notifyChanged()
        }
    }
    
    func getLogList(completion: (([MakeupLog]) -> Void)) {
        completion(logList)
    }
    
    func insertMakeupLog(title: String, body: String?, image: UIImage, completion: (MakeupLog?) -> Void) {
        defer {
            notifyChanged()
        }
        if logList.isEmpty {
            let id = MakeupLog.ID(idNumber: 0)
            let log = MakeupLog(id: id,
                                title: title,
                                body: body,
                                image: image,
                                partsList: [])
            logMap[id] = log
            completion(log)
            
            return
        }
        let nextID = logList.last!.id.makeNextID()
        let log = MakeupLog(id: nextID,
                            title: title,
                            body: body,
                            image: image,
                            partsList: [])
        logMap[nextID] = log
        completion(log)
    }
    
    func updateFacePart(logID: MakeupLog.ID, part: FacePart, completion: (MakeupLog?) -> Void) {
        if var log = logMap[logID],
           let index = log.partsList.firstIndex(where: {$0.id == part.id}) {
            log.partsList[index] = part
            logMap[logID] = log
            completion(log)
            notifyChanged()
        } else {
            completion(nil)
        }
    }
    
    func insertFacePart(logID: MakeupLog.ID, type: String, image: UIImage, completion: (MakeupLog?) -> Void) {
        guard var log = logMap[logID] else {
            completion(nil)
            return
        }
        let nextID: FacePart.ID
        if log.partsList.isEmpty {
            nextID = FacePart.ID(idNumber: 0)
        } else {
            nextID = log.partsList.last!.id.makeNextID()
        }
        let part = FacePart(id: nextID, type: type, image: image,
                            annotations: [])
        log.partsList.append(part)
        logMap[logID] = log
        completion(log)
        notifyChanged()
    }
    
    func updateFaceAnnotation(logID: MakeupLog.ID, partID: FacePart.ID, faceAnnotation: FaceAnnotation, completion: (MakeupLog?) -> Void) {
        if var log = logMap[logID],
           let partIndex = log.partsList.firstIndex(where: {$0.id == partID}),
           let faceIndex = logMap[logID]?.partsList[partIndex].annotations.firstIndex(where: {$0.id == faceAnnotation.id}) {
            log.partsList[partIndex].annotations[faceIndex] = faceAnnotation
            logMap[logID] = log
            completion(log)
            notifyChanged()
        } else {
            completion(nil)
        }
    }
    
    func insertFaceAnnotation(logID: MakeupLog.ID, partID: FacePart.ID, completion: (MakeupLog?) -> Void) {
        if var log = logMap[logID],
           let partIndex = log.partsList.firstIndex(where: {$0.id == partID}) {
            let id = log.partsList[partIndex].makeNextFaceAnnotationID()
            let faceAnnotation = FaceAnnotation(id: id, text: String(id.id))
            log.partsList[partIndex].annotations.append(faceAnnotation)
            logMap[logID] = log
            completion(log)
            notifyChanged()
        } else {
            completion(nil)
        }
    }
    
    private func notifyChanged() {
        NotificationCenter.default.post(name: .didLogUpdate, object: nil)
    }
}
