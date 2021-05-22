//
//  FaceAnnotationRepository.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import UIKit
import RealmSwift

protocol MakeupLogRepository {
    func getLogList(completion: ([MakeupLog]) -> Void)
    func insertMakeupLog(title: String, body: String?, image: UIImage, completion: (MakeupLog?) -> Void)
    func updateFacePart(logID: MakeupLogID, part: FacePart, completion: (MakeupLog?) -> Void)
    func insertFacePart(logID: MakeupLogID, type: String, image: UIImage, completion: (MakeupLog?) -> Void)
    func updateFaceAnnotation(logID: MakeupLogID, partID: FacePartID, faceAnnotation: FaceAnnotation, completion: (MakeupLog?) -> Void)
    func insertFaceAnnotation(logID: MakeupLogID, partID: FacePartID, completion: (MakeupLog?) -> Void)
    
    var logMap: [MakeupLogID: MakeupLog] { get }
}

class MakeupLogRealmRepository: MakeupLogRepository {
    var logMap: [MakeupLogID : MakeupLog] {
        let result = Array(realm.objects(MakeupLog.self).map { $0 })
        var dic = [MakeupLogID : MakeupLog]()
        result.forEach {
            dic[$0.id!] = $0
        }
        return dic
    }
    
    
    private var realm: Realm!
    static let shared = MakeupLogRealmRepository()
    
    private init() {
        var config = Realm.Configuration.init()
        config.schemaVersion = 0
        realm = try! Realm(configuration: config)
    }
    
    func getLogList(completion: ([MakeupLog]) -> Void) {
        let result = realm.objects(MakeupLog.self).map { $0 }
        let array = Array(result)
        completion(array)
    }
    
    func compressData(image: UIImage) -> Data? {
        guard let count = image.pngData()?.count else {
            return nil
        }
        if count > 1 * 1024 * 1024 {
            return image.jpegData(compressionQuality: 0.5)
        }
        return image.pngData()
    }
    
    func insertMakeupLog(title: String, body: String?, image: UIImage, completion: (MakeupLog?) -> Void) {
        defer {
            notifyChanged()
        }
        let result = realm.objects(MakeupLog.self).map { $0 }
        let array = Array(result)
        let log: MakeupLog
        if array.isEmpty {
            let id = MakeupLogID(id: 0)
            log = MakeupLog.make(id: id,
                                     title: title,
                                     body: body,
                                     image: compressData(image: image)!,
                                     partsList: [])
        } else {
            let nextID = array.last!.id!.makeNextID()
            log = MakeupLog.make(id: nextID,
                                title: title,
                                body: body,
                                image: compressData(image: image)!,
                                partsList: [])
        }
        
        do {
            try realm.write {
                realm.add(log)
                completion(log)
            }
        } catch {
            print(#function + "insert failed")
            completion(nil)
        }
    }
    
    func updateFacePart(logID: MakeupLogID, part: FacePart, completion: (MakeupLog?) -> Void) {
        let result = realm.objects(MakeupLog.self).map { $0 }
        let array = Array(result)
        
        guard let log = array.first(where: {$0.id == logID}),
              let index = log.partsList.firstIndex(where: {$0.id == part.id}) else {
            completion(nil)
            return
        }
        
        do {
            try realm.write {
                log.partsList[index] = part
                completion(log)
                notifyChanged()
            }
        } catch {
            print(#function + "updateFaceParts")
            completion(nil)
        }
    }
    
    func insertFacePart(logID: MakeupLogID, type: String, image: UIImage, completion: (MakeupLog?) -> Void) {
        let result = realm.objects(MakeupLog.self).map { $0 }
        let array = Array(result)
        guard let log = array.first(where: {$0.id == logID}),
              let data = compressData(image: image) else {
            completion(nil)
            return
        }
        
        let nextID: FacePartID
        if log.partsList.isEmpty {
            nextID = FacePartID()
        } else {
            nextID = log.partsList.last!.id!.makeNextID()
        }
        let part = FacePart.make(id: nextID,
                                 type: type,
                                 image: data,
                                 annotations: [])
        do {
            try realm.write {
                log.partsList.append(part)
            }
        } catch {
            print(#function + "パーツ追加失敗")
            fatalError()
        }
    }
    
    func updateFaceAnnotation(logID: MakeupLogID, partID: FacePartID, faceAnnotation: FaceAnnotation, completion: (MakeupLog?) -> Void) {
        let result = realm.objects(MakeupLog.self).map { $0 }
        let array = Array(result)
        guard let log = array.first(where: {$0.id == logID}),
              let partIndex = log.partsList.firstIndex(where: {$0.id == partID}),
                 let faceIndex = log.partsList[partIndex].annotations.firstIndex(where: {$0.id == faceAnnotation.id}) else {
            completion(nil)
            return
        }
        let part = log.partsList[partIndex]
        part.annotations[faceIndex] = faceAnnotation
        updateFacePart(logID: logID,
                       part: part) { log in
            completion(log)
            notifyChanged()
        }
    }
    
    func insertFaceAnnotation(logID: MakeupLogID, partID: FacePartID, completion: (MakeupLog?) -> Void) {
        let result = realm.objects(MakeupLog.self).map { $0 }
        let array = Array(result)
        guard let log = array.first(where: {$0.id == logID}),
              let partIndex = log.partsList.firstIndex(where: {$0.id == partID}) else {
            completion(nil)
            return
        }
        let part = log.partsList[partIndex]
        let faceID = part.makeNextFaceAnnotationID()
        let faceAnnotation = FaceAnnotation()
        faceAnnotation.id = faceID
        faceAnnotation.text = String(faceID.id)
        part.annotations.append(faceAnnotation)
        updateFacePart(logID: logID, part: part) { log in
            completion(log)
            notifyChanged()
        }
    }
    
    private func notifyChanged() {
        NotificationCenter.default.post(name: .didLogUpdate, object: nil)
    }
    
}

class MakeupLogRepositoryInMemory: MakeupLogRepository {
    static let shared = MakeupLogRepositoryInMemory()
    
    let id = MakeupLogID(id: 1)
    lazy var log: MakeupLog = MakeupLog.make(id: id,
                                             title: "makeup_sample",
                                             image: #imageLiteral(resourceName: "sample_face").pngData()!,
                                             partsList: [eye])
    lazy var eye: FacePart = { FacePart.make(id: {
        let id = FacePartID()
        id.id = 0
        return id
    }(),
    type: "eye",
    image: #imageLiteral(resourceName: "sample_eye_line").pngData()!,
    annotations: [eyeAnnotation])}()
    
    
    lazy var faceID: FaceAnnotationID = {
        let id = FaceAnnotationID()
        id.id = 1
        return id
    }()
    
    
    lazy var eyeAnnotation: FaceAnnotation = {
        let annotation = FaceAnnotation()
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
    
    lazy var colorPalletAnnotation1 = ColorPalletAnnotation.make(id: colorID1,
                                                                 text: "1",
                                                                 pointRatioOnImage: PointRatio())
    lazy var colorPalletAnnotation2 = ColorPalletAnnotation.make(id: colorID2,
                                                                 text: "2",
                                                                 pointRatioOnImage: {
                                                                    let ratio = PointRatio()
                                                                    ratio.x = 0.3
                                                                    return ratio
                                                                 }())
    lazy var colorPalletAnnotation3 = ColorPalletAnnotation.make(id: colorID3,
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
    
    private init() {}
    
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
                                     image: image.pngData()!,
                                     partsList: [])
            logMap[id] = log
            completion(log)
            
            return
        }
        let nextID = logList.last!.id!.makeNextID()
        let log = MakeupLog.make(id: nextID,
                                 title: title,
                                 body: body,
                                 image: image.pngData()!,
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
        let nextID: FacePartID
        if log.partsList.isEmpty {
            nextID = FacePartID()
        } else {
            nextID = log.partsList.last!.id!.makeNextID()
        }
        let part = FacePart.make(id: nextID, type: type, image: image.pngData()!,
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
            log.partsList[partIndex].annotations[faceIndex] = faceAnnotation
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
            let faceAnnotation = FaceAnnotation()
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
