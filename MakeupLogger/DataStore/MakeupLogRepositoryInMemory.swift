//
//  MakeupLogRepositoryInMemory.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/06/27.
//

import Foundation
import UIKit

class MakeupLogRepositoryInMemory: MakeupLogRepository {
    static let shared = MakeupLogRepositoryInMemory()
    
    var nextID: FacePartID? = nil
    
    let id = MakeupLogID(id: 1)
    var imagePath = ""
    
    lazy var log: MakeupLog = MakeupLog.make(id: id,
                                             title: "makeup_sample",
                                             imagePath: imagePath,
                                             partsList: [eye])
    lazy var eye: FacePart = {
        let id = FacePartID()
        return FacePart.make(id: id,
                             type: "eye",
                             imagePath: saveImage(folderName: id.folderName,
                                                                              fileName: id.fileName,
                                                                              pngData: #imageLiteral(resourceName: "sample_eye_line").pngData()!),
                             annotations: [eyeAnnotation])}()
    
    
    lazy var faceID: FaceAnnotationID = {
        let id = FaceAnnotationID()
        id.id = 1
        return id
    }()
    
    
    lazy var eyeAnnotation: FaceAnnotationObject = {
        let annotation = FaceAnnotationObject()
        annotation.id = faceID
        annotation.text = "1"
        annotation.pointRatioOnImage = {
            let ratio = PointRatio()
            ratio.x = 0.1
            ratio.y = 0.2
            return ratio
        }()
        annotation.comment = "暗めにする"
        annotation.selectedColorPalletID = ColorPalletID()
        annotation.selectedColorPalletAnnotationID = colorID1
        return annotation
    }()
    
    lazy var colorID1: ColorPalletAnnotationID = {
        let id = ColorPalletAnnotationID()
        id.id = 1
        return id
    }()
    lazy var colorID2: ColorPalletAnnotationID = {
        let id = ColorPalletAnnotationID()
        id.id = 2
        return id
    }()
    lazy var colorID3: ColorPalletAnnotationID = {
        let id = ColorPalletAnnotationID()
        id.id = 3
        return id
    }()
    
    lazy var colorPalletAnnotation1 = ColorPalletAnnotationObject.make(id: colorID1,
                                                                 text: "1",
                                                                 pointRatioOnImage: PointRatio())
    lazy var colorPalletAnnotation2 = ColorPalletAnnotationObject.make(id: colorID2,
                                                                 text: "2",
                                                                 pointRatioOnImage: {
                                                                    let ratio = PointRatio()
                                                                    ratio.x = 0.3
                                                                    return ratio
                                                                 }())
    lazy var colorPalletAnnotation3 = ColorPalletAnnotationObject.make(id: colorID3,
                                                                 text: "3",
                                                                 pointRatioOnImage: {
                                                                    let ratio = PointRatio()
                                                                    ratio.x = 0.6
                                                                    return ratio
                                                                 }())
    
    lazy var logMap = [id: log]
    
    private var logList: [MakeupLog] {
        logMap.values.map {$0 as MakeupLog}
    }
    
    private init() {
        let sample = #imageLiteral(resourceName: "sample_face").pngData()!
        imagePath = saveImage(folderName: id.folderName(), fileName: id.filename(), pngData: sample)
    }
    
    func setLog(logMap: [MakeupLogID: MakeupLog]? = nil) {
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
            let id = MakeupLogID(id: 0)
            let log = MakeupLog.make(id: id,
                                     title: title,
                                     body: body,
                                     imagePath: saveImage(folderName: id.folderName(), fileName: id.filename(), pngData: image.pngData()!),
                                     partsList: [])
            logMap[id] = log
            completion(log)
            
            return
        }
        let nextID = logList.last!.id!.makeNextID()
        let log = MakeupLog.make(id: nextID,
                                 title: title,
                                 body: body,
                                 imagePath: saveImage(folderName: id.folderName(), fileName: id.filename(), pngData: image.pngData()!),
                                 partsList: [])
        logMap[nextID] = log
        completion(log)
    }
    
    func updateFacePart(logID: MakeupLogID, part: FacePart, completion: (MakeupLog?) -> Void) {
        if let log = logMap[logID],
           let index = log.partsList.firstIndex(where: {$0.id == part.id}) {
            log.partsList[index] = part
            logMap[logID] = log
            completion(log)
            notifyChanged()
        } else {
            completion(nil)
        }
    }
    
    func insertFacePart(logID: MakeupLogID, type: String, image: UIImage, completion: (MakeupLog?) -> Void) {
        guard let log = logMap[logID] else {
            completion(nil)
            return
        }
        let id: FacePartID
        if let nextID = nextID {
            id = nextID
        } else {
            id = FacePartID()
        }
        let part = FacePart.make(id: id,
                                 type: type,
                                 imagePath: saveImage(folderName: id.folderName, fileName: id.folderName, pngData: image.pngData()!),
                            annotations: [])
        log.partsList.append(part)
        logMap[logID] = log
        completion(log)
        notifyChanged()
    }
    
    func updateFaceAnnotation(logID: MakeupLogID, partID: FacePartID, faceAnnotation: FaceAnnotation, completion: (MakeupLog?) -> Void) {
        if let log = logMap[logID],
           let partIndex = log.partsList.firstIndex(where: {$0.id == partID}),
           let faceIndex = logMap[logID]?.partsList[partIndex].annotations.firstIndex(where: {$0.id == faceAnnotation.id}) {
            log.partsList[partIndex].annotations[faceIndex] = faceAnnotation.makeObject()
            logMap[logID] = log
            completion(log)
            notifyChanged()
        } else {
            completion(nil)
        }
    }
    
    func insertFaceAnnotation(logID: MakeupLogID, partID: FacePartID, completion: (MakeupLog?) -> Void) {
        if let log = logMap[logID],
           let partIndex = log.partsList.firstIndex(where: {$0.id == partID}) {
            let id = log.partsList[partIndex].makeNextFaceAnnotationID()
            let faceAnnotation = FaceAnnotationObject()
            faceAnnotation.id = id
            faceAnnotation.text = String(id.id)
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
