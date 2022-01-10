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
    func updateMakeupLog(logID: MakeupLogID, image: UIImage) -> MakeupLog?
    func updateFacePart(logID: MakeupLogID, part: FacePart, image: UIImage?, completion: (MakeupLog?) -> Void)
    func insertFacePart(logID: MakeupLogID, type: String, image: UIImage, completion: (MakeupLog?) -> Void)
    func updateFaceAnnotation(logID: MakeupLogID, partID: FacePartID, faceAnnotation: FaceAnnotation, completion: (MakeupLog?) -> Void)
    func insertFaceAnnotation(logID: MakeupLogID, partID: FacePartID, completion: (MakeupLog?) -> Void)
    func delete(logID: MakeupLogID)
    func delete(logID: MakeupLogID, partID: FacePartID, annotation: FaceAnnotationID)
    
}

extension MakeupLogRepository {
    func saveImage(folderName: String, fileName: String, pngData: Data) -> String {
        do {
            try FileIOUtil.saveToDocument(folderName: folderName, fileName: fileName, data: pngData)
        } catch {
            print("🥲ColorPallet画像の保存に失敗しました🥲")
        }
        
        return folderName + "/" + fileName
    }
    
    func imageData(imagePath: String) -> Data? {
        return FileIOUtil.getImageDataFromDocument(path: imagePath)
    }
}

class MakeupLogRealmRepository: MakeupLogRepository {

    private var realm: Realm!
    static let shared = MakeupLogRealmRepository()
    
    private init() {
        var config = Realm.Configuration.init()
        config.schemaVersion = RealmConfig.version
        realm = try! Realm(configuration: config)
    }
    
    func getLogList(completion: ([MakeupLog]) -> Void) {
        let result = realm.objects(MakeupLog.self).map { $0 }
        let array = Array(result)
        completion(array)
    }
    
    func insertMakeupLog(title: String, body: String?, image: UIImage, completion: (MakeupLog?) -> Void) {
        defer {
            notifyChanged()
        }
        let log: MakeupLog
        let id = MakeupLogID()
        let imagePath = saveImage(folderName: id.folderName(),
                                  fileName: id.filename(),
                                  pngData: image.compressData()!)
        log = MakeupLog.make(id: id,
                             title: title,
                             body: body,
                             imagePath: imagePath)
        
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
    
    func updateMakeupLog(logID: MakeupLogID, image: UIImage) -> MakeupLog? {
        defer {
            notifyChanged()
        }
        do {
            guard let target = realm.objects(MakeupLog.self).first(where: {$0.id == logID}) else {
                print("更新対象が見つからない")
                return nil
            }
            try realm.write {
                let imagePath = saveImage(folderName: logID.folderName(),
                                          fileName: logID.filename(),
                                          pngData: image.compressData()!)
                target.imagePath = imagePath
            }
            return target
        } catch {
            print(#function + "画像更新に失敗しました")
            return nil
        }
    }
    
    func updateFacePart(logID: MakeupLogID, part: FacePart, image: UIImage?, completion: (MakeupLog?) -> Void) {
        let result = realm.objects(MakeupLog.self).map { $0 }
        let array = Array(result)
        
        guard let log = array.first(where: {$0.id == logID}),
              let index = log.partsList.firstIndex(where: {$0.id == part.id}) else {
            completion(nil)
            return
        }
        do {
            try realm.write {
                if let image = image,
                   let data = image.compressData() {
                    let imagePath = saveImage(folderName: part.id!.folderName, fileName: part.id!.fileName, pngData: data)
                    part.imagePath = imagePath
                }
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
              let data = image.compressData() else {
            completion(nil)
            return
        }
        
        let nextID = FacePartID()
        let imagePath = saveImage(folderName: nextID.folderName, fileName: nextID.fileName, pngData: data)
            
        let part = FacePart.make(id: nextID,
                                 type: type,
                                 imagePath: imagePath,
                                 annotations: [])
        do {
            try realm.write {
                log.partsList.append(part)
                completion(log)
                notifyChanged()
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
        do {
            try realm.write {
                log.partsList[partIndex].annotations[faceIndex] = faceAnnotation.makeObject()
                completion(log)
                notifyChanged()
            }
        } catch {
            print(#function + "error")
            completion(nil)
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
        let faceAnnotation = FaceAnnotationObject()
        faceAnnotation.text = String(log.partsList[partIndex].annotations.count + 1)
        do {
            try realm.write {
                log.partsList[partIndex].annotations.append(faceAnnotation)
                completion(log)
                notifyChanged()
            }
        } catch {
            print(#function + "error")
            completion(nil)
        }
        
    }
    
    private func notifyChanged() {
        NotificationCenter.default.post(name: .didLogUpdate, object: nil)
    }
    
    func delete(logID: MakeupLogID) {
        
        let result = realm.objects(MakeupLog.self).map { $0 }
        guard let target = result.first(where: { log in
            log.id == logID
        }) else {
            return
        }
        do {
            try realm.write({
                realm.delete(target)
            })
        } catch {
            print(#function + error.localizedDescription)
        }
    }
    
    func delete(logID: MakeupLogID, partID: FacePartID, annotation: FaceAnnotationID) {
        let result = realm.objects(MakeupLog.self).map { $0 }
        guard let target = result.first(where: { log in
            log.id == logID
        }) else {
            return
        }
        do {
            try realm.write({
                if let part = target.partsList.first(where: { $0.id == partID }),
                   let index = part.annotations.firstIndex(where: { obj in
                       obj.id == annotation
                   }) {
                    part.annotations.remove(at: index)
                }
            })
        } catch {
            print(#function + error.localizedDescription)
        }
    }
    
}

