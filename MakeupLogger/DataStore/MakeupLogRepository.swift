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
    func updateFacePart(logID: String, part: FacePart, completion: (MakeupLog?) -> Void)
    func insertFacePart(logID: String, type: String, image: UIImage, completion: (MakeupLog?) -> Void)
    func updateFaceAnnotation(logID: String, partID: FacePart.ID, faceAnnotation: FaceAnnotation, completion: (MakeupLog?) -> Void)
    func insertFaceAnnotation(logID: String, partID: FacePart.ID, faceAnnotation: FaceAnnotation, completion: (MakeupLog?) -> Void)
    
    var logMap: [String: MakeupLog] { get }
}

class MakeupLogRepositoryInMemory: MakeupLogRepository {
    static let shared = MakeupLogRepositoryInMemory()
    
    let id = "makeupLog_1"
    lazy var log: MakeupLog = MakeupLog(id: id, title: "makeup_sample", image: #imageLiteral(resourceName: "sample_face"),
                                        partsList: [eye])
    lazy var eye: FacePart = { FacePart(id: FacePart.ID(idNumber: 1), type: "eye", image: #imageLiteral(resourceName: "sample_eye_line"),
                                        annotations: [eyeAnnotation])}()
    lazy var eyeAnnotation: FaceAnnotation = { FaceAnnotation(id: "eye_1",
                                                              text: "1",
                                                              pointRatioOnImage: PointRatio(x: 0.1, y: 0.2),
                                                              comment: Comment(text: "暗めにする"),
                                                              colorPallet: colorPallet,
                                                              selectedColorPalletAnnotationID: "1")}()
    
    let colorPalletAnnotation1 = ColorPalletAnnotation(id: "1",
                                                       text: "1",
                                                       pointRatioOnImage: PointRatio(x: 0, y: 0))
    let colorPalletAnnotation2 = ColorPalletAnnotation(id: "2",
                                                       text: "2",
                                                       pointRatioOnImage: PointRatio(x: 0.3, y: 0))
    let colorPalletAnnotation3 = ColorPalletAnnotation(id: "3",
                                                       text: "3",
                                                       pointRatioOnImage: PointRatio(x: 0.6, y: 0))
    lazy var colorPallet = ColorPallet(id: ColorPallet.ColorPalletID(id: "test"),
                                       title: "color_pallet",
                                       imageFileName: "sample_color_pallet",
                                       annotationList: [colorPalletAnnotation1,
                                                        colorPalletAnnotation2,
                                                        colorPalletAnnotation3])
    
    lazy var logMap = [id: log]
    
    private var logList: [MakeupLog] {
        logMap.values.map {$0 as MakeupLog}
    }
    
    private init() {}
    
    func setLog(logMap: [String: MakeupLog]? = nil) {
        if let map = logMap {
            self.logMap = map
        }
    }
    
    func getLogList(completion: (([MakeupLog]) -> Void)) {
        completion(logList)
    }
    
    func updateFacePart(logID: String, part: FacePart, completion: (MakeupLog?) -> Void) {
        if var log = logMap[logID],
           let index = log.partsList.firstIndex(where: {$0.id == part.id}) {
            log.partsList[index] = part
            logMap[logID] = log
            completion(log)
        } else {
            completion(nil)
        }
    }
    
    func insertFacePart(logID: String, type: String, image: UIImage, completion: (MakeupLog?) -> Void) {
        if var log = logMap[logID],
           let id = log.partsList.last?.id.makeNextID() {
            let part = FacePart(id: id, type: type, image: image,
                                annotations: [])
            log.partsList.append(part)
            logMap[logID] = log
            completion(log)
        } else {
            completion(nil)
        }
    }
    
    func updateFaceAnnotation(logID: String, partID: FacePart.ID, faceAnnotation: FaceAnnotation, completion: (MakeupLog?) -> Void) {
        if var log = logMap[logID],
           let partIndex = log.partsList.firstIndex(where: {$0.id == partID}),
           let faceIndex = logMap[logID]?.partsList[partIndex].annotations.firstIndex(where: {$0.id == faceAnnotation.id}) {
            log.partsList[partIndex].annotations[faceIndex] = faceAnnotation
            logMap[logID] = log
            completion(log)
        } else {
            completion(nil)
        }
    }
    
    func insertFaceAnnotation(logID: String, partID: FacePart.ID, faceAnnotation: FaceAnnotation, completion: (MakeupLog?) -> Void) {
        if var log = logMap[logID],
           let partIndex = log.partsList.firstIndex(where: {$0.id == partID}) {
            log.partsList[partIndex].annotations.append(faceAnnotation)
            logMap[logID] = log
            completion(log)
        } else {
            completion(nil)
        }
    }
}
