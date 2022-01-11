//
//  ColorPalletRepository.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/03/28.
//

import Foundation
import UIKit
import RealmSwift

protocol ColorPalletRepository {
    func getColorPalletList(completion: ([ColorPallet]) -> Void)
    func insertColorPallet(title: String,
                           image: UIImage?,
                           completion: (ColorPallet?) -> Void)
    func updateColorPallet(id: ColorPalletID,
                           title: String,
                           image: UIImage?,
                           annotations: [ColorPalletAnnotation],
                           completion: (ColorPallet?) -> Void)
    func updateAnnotation(id: ColorPalletID,
                          annotation: ColorPalletAnnotation,
                          completion: (ColorPallet?) -> Void)
    func insertAnnotation(id: ColorPalletID,
                          completion: (ColorPallet?) -> Void)
    func delete(id: ColorPalletID)
}

extension ColorPalletRepository {
    static func saveImage(folderName: String, fileName: String, pngData: Data) -> String {
        do {
            try FileIOUtil.saveToDocument(folderName: folderName, fileName: fileName, data: pngData)
        } catch {
            print("🥲ColorPallet画像の保存に失敗しました🥲")
        }
        
        return folderName + "/" + fileName
    }
    
    static func imageData(imagePath: String) -> Data? {
        return FileIOUtil.getImageDataFromDocument(path: imagePath)
    }
}

class ColorPalletRealmRepository: ColorPalletRepository {
    
    private var realm: Realm!
    
    static let shared = ColorPalletRealmRepository()
    private init() {
        var config = Realm.Configuration.init()
        config.schemaVersion = RealmConfig.version
        realm = try! Realm(configuration: config)
    }
    
    func getColorPalletList(completion: ([ColorPallet]) -> Void) {
        let result = realm.objects(ColorPallet.self).map { $0 }
        let array = Array(result)
        completion(array)
    }
    
    func insertColorPallet(title: String, image: UIImage?, completion: (ColorPallet?) -> Void) {
        let pallet: ColorPallet
        let id = ColorPalletID()
        let path: String?
        if let data = image?.compressData() {
            path = Self.saveImage(folderName: id.folderName(), fileName: id.filename(), pngData: data)
        } else {
            path = nil
        }
        
        pallet = ColorPallet.make(id: id,
                                  title: title,
                                  imagePath: path,
                                  annotationList: [])
        do {
            try realm.write {
                realm.add(pallet)
                completion(pallet)
                notifyChanged()
            }
        } catch {
            print(#function + "insert failed")
            completion(nil)
        }
    }
    
    func updateColorPallet(id: ColorPalletID, title: String, image: UIImage?, annotations: [ColorPalletAnnotation], completion: (ColorPallet?) -> Void) {
        let result = realm.objects(ColorPallet.self).map { $0 }
        let array = Array(result)
        guard let pallet = array.first(where: {$0.id == id}) else {
            completion(nil)
            return
        }
        do {
            
            try realm.write {
                pallet.title = title
                if let data = image?.compressData() {
                    let path = Self.saveImage(folderName: id.folderName(), fileName: id.filename(), pngData: data)
                    pallet.imagePath = path
                }
                for (i, annotation) in annotations.enumerated() {
                    pallet.annotationList[i] = annotation.makeObject()
                }
                completion(pallet)
                notifyChanged()
            }
        } catch {
            print(#function + "update failed")
            completion(nil)
        }
        
    }
    
    func updateAnnotation(id: ColorPalletID, annotation: ColorPalletAnnotation, completion: (ColorPallet?) -> Void) {
        let result = realm.objects(ColorPallet.self).map { $0 }
        let array = Array(result)
        guard let pallet = array.first(where: {$0.id == id}),
              let index = pallet.annotationList.firstIndex(where: {
                $0.id == annotation.id
              }) else {
            completion(nil)
            return
        }
        do {
            try realm.write {
                pallet.annotationList[index] = annotation.makeObject()
                completion(pallet)
                notifyChanged()
            }
        } catch {
            print(#function + "update failed")
            completion(nil)
        }
    }
    
    func insertAnnotation(id: ColorPalletID, completion: (ColorPallet?) -> Void) {
        let result = realm.objects(ColorPallet.self).map { $0 }
        let array = Array(result)
        guard let pallet = array.first(where: {$0.id == id}) else {
            completion(nil)
            return
        }
        let annotationID = ColorPalletAnnotationID()
        let annotation = ColorPalletAnnotationObject.make(id: annotationID,
                                                          text: (pallet.annotationList.count + 1).description,
                                                          pointRatioOnImage: .zero, title: "")
        do {
            try realm.write {
                pallet.annotationList.append(annotation)
            }
        } catch {
            print(#function + "insert failed")
        }
        completion(pallet)
        notifyChanged()
    }
    
    private func notifyChanged() {
        NotificationCenter.default.post(name: .didColorPalletUpdate, object: nil)
    }
    
    func delete(id: ColorPalletID) {
        let result = realm.objects(ColorPallet.self).map { $0 }
        let array = Array(result)
        guard let pallet = array.first(where: {$0.id == id}) else {
            return
        }
        do {
            try realm.write({
                realm.delete(pallet)
            })
        } catch {
            print(#function + error.localizedDescription)
        }
    }

}

