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
    
    var nextFacePartID: FacePartID? = nil
    var nextFaceAnnotationID: FaceAnnotationID? = nil
    
    let id = MakeupLogID()
    var imagePath = ""
    
    lazy var log: MakeupLog = {
        let log = MakeupLog.make(id: id,
                                 title: "makeup_sample",
                                 imagePath: imagePath)
        log.partsList[0] = eye
        return log
    }()
    
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
        return id
    }()
    lazy var colorID2: ColorPalletAnnotationID = {
        let id = ColorPalletAnnotationID()
        return id
    }()
    lazy var colorID3: ColorPalletAnnotationID = {
        let id = ColorPalletAnnotationID()
        return id
    }()
    
    lazy var colorPalletAnnotation1 = ColorPalletAnnotationObject.make(id: colorID1,
                                                                 text: "1",
                                                                       pointRatioOnImage: PointRatio(), title: "AAA")
    lazy var colorPalletAnnotation2 = ColorPalletAnnotationObject.make(id: colorID2,
                                                                 text: "2",
                                                                 pointRatioOnImage: {
                                                                    let ratio = PointRatio()
                                                                    ratio.x = 0.3
                                                                    return ratio
    }(), title: "BBB")
    lazy var colorPalletAnnotation3 = ColorPalletAnnotationObject.make(id: colorID3,
                                                                 text: "3",
                                                                 pointRatioOnImage: {
                                                                    let ratio = PointRatio()
                                                                    ratio.x = 0.6
                                                                    return ratio
    }(), title: "CCC")
    
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
        let id = MakeupLogID()
        let log = MakeupLog.make(id: id,
                                 title: title,
                                 body: body,
                                 imagePath: saveImage(folderName: id.folderName(), fileName: id.filename(), pngData: image.pngData()!))
        logMap[id] = log
        completion(log)
    }
    
    func updateMakeupLog(logID: MakeupLogID, image: UIImage) -> MakeupLog? {
        defer {
            notifyChanged()
        }
        let target = logMap[logID]!
        let path = saveImage(folderName: target.id!.folderName(), fileName: target.id!.filename(), pngData: image.compressData()!)
        logMap[logID]?.imagePath = path
        return logMap[logID]
    }
    
    func updateFacePart(logID: MakeupLogID, part: FacePart, image: UIImage?, completion: (MakeupLog?) -> Void) {
        if let log = logMap[logID],
           let index = log.partsList.firstIndex(where: {$0.id == part.id}) {
            if let image = image,
               let data = image.compressData() {
                let imagePath = saveImage(folderName: part.id!.folderName, fileName: part.id!.fileName, pngData: data)
                part.imagePath = imagePath
            }
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
        if let nextID = nextFacePartID {
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
            let faceAnnotation = FaceAnnotationObject()
            if let nextID = nextFaceAnnotationID {
                faceAnnotation.id = nextID
            }
            faceAnnotation.text = String(log.partsList[partIndex].annotations.count)
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
    
    func delete(logID: MakeupLogID) {
        logMap.removeValue(forKey: logID)
    }
    
    func delete(logID: MakeupLogID, partID: FacePartID, annotation: FaceAnnotationID) -> MakeupLog? {
        if let part = logMap[logID]?.partsList.first(where: { part in
            part.id == partID
        }),
           let index = part.annotations.firstIndex(where: { obj in
               obj.id == annotation
           }){
            part.annotations.remove(at: index)
        }
        return logMap[logID]
    }
}
