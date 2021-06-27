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
                           image: UIImage,
                           completion: (ColorPallet?) -> Void)
    func updateColorPallet(id: ColorPalletID,
                           title: String,
                           image: UIImage,
                           completion: (ColorPallet?) -> Void)
    func updateAnnotation(id: ColorPalletID,
                          annotation: ColorPalletAnnotation,
                          completion: (ColorPallet?) -> Void)
    func insertAnnotation(id: ColorPalletID,
                          completion: (ColorPallet?) -> Void)
    
    var cache: [ColorPalletID: ColorPallet] { get }
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
    
    var cache: [ColorPalletID : ColorPallet] {
        get {
            let result = realm.objects(ColorPallet.self).map { $0 }
            let array = Array(result)
            var dic = [ColorPalletID : ColorPallet]()
            array.forEach {
                dic[$0.id!] = $0
            }
            return dic
        }
        
    }
    
    func getColorPalletList(completion: ([ColorPallet]) -> Void) {
        let result = realm.objects(ColorPallet.self).map { $0 }
        let array = Array(result)
        completion(array)
    }
    
    func insertColorPallet(title: String, image: UIImage, completion: (ColorPallet?) -> Void) {
        guard let data = image.compressData() else {
            completion(nil)
            return
        }
        let result = realm.objects(ColorPallet.self).map { $0 }
        let array = Array(result)
        let pallet: ColorPallet
        if array.isEmpty {
            let id = ColorPalletID()
            let path = Self.saveImage(folderName: id.folderName(), fileName: id.filename(), pngData: data)
            pallet = ColorPallet.make(id: id,
                                      title: title,
                                      imagePath: path,
                                      annotationList: [])
        } else {
            let nextID = array.last!.id!.makeNextID()
            let path = Self.saveImage(folderName: nextID.folderName(), fileName: nextID.filename(), pngData: data)
            pallet = ColorPallet.make(id: nextID,
                                      title: title,
                                      imagePath: path,
                                      annotationList: [])
        }
        
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
    
    func updateColorPallet(id: ColorPalletID, title: String, image: UIImage, completion: (ColorPallet?) -> Void) {
        guard let pallet = cache[id],
            let data = image.compressData() else {
            completion(nil)
            return
        }
        do {
            let path = Self.saveImage(folderName: id.folderName(), fileName: id.filename(), pngData: data)
            try realm.write {
                pallet.title = title
                pallet.imagePath = path
                completion(pallet)
                notifyChanged()
            }
        } catch {
            print(#function + "update failed")
            completion(nil)
        }
        
    }
    
    func updateAnnotation(id: ColorPalletID, annotation: ColorPalletAnnotation, completion: (ColorPallet?) -> Void) {
        guard let pallet = cache[id],
              let index = pallet.annotationList.firstIndex(where: {
                $0.id == annotation.id
              }) else {
            completion(nil)
            return
        }
        do {
            try realm.write {
                pallet.annotationList[index] = annotation.makeObject()
            }
        } catch {
            print(#function + "update failed")
        }
        completion(pallet)
        notifyChanged()
    }
    
    func insertAnnotation(id: ColorPalletID, completion: (ColorPallet?) -> Void) {
        guard let pallet = cache[id] else {
            completion(nil)
            return
        }
        let list = pallet.annotationList
        if list.isEmpty {
            let annotationID = ColorPalletAnnotationID()
            annotationID.id = 0
            let annotation = ColorPalletAnnotationObject.make(id: annotationID,
                                                   text: annotationID.id.description,
                                                   pointRatioOnImage: .zero)
            do {
                try realm.write {
                    pallet.annotationList.append(annotation)
                }
            } catch {
                print(#function + "insert failed")
            }
            completion(pallet)
            notifyChanged()
            return
        }
        let annotationID = list.last!.id!.makeNextAnnotationID()
        let annotation = ColorPalletAnnotationObject.make(id: annotationID,
                                                    text: annotationID.id.description,
                                                    pointRatioOnImage: .zero)
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
}

class ColorPalletRepositoryInMemory: ColorPalletRepository {
    static let shared = ColorPalletRepositoryInMemory()
    
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
    lazy var colorPalletId: ColorPalletID = {
        let id = ColorPalletID()
        id.id = 0
        return id
    }()
    
    lazy var colorPallet: ColorPallet = {
        let path = Self.saveImage(folderName: colorPalletId.folderName(),
                                  fileName: colorPalletId.filename(),
                                  pngData: UIImage(named: "sample_color_pallet")!.compressData()!)
        let pallet = ColorPallet.make(id: colorPalletId,
                                      title: "color_pallet",
                                      imagePath: path,
                                      annotationList: [colorPalletAnnotation1,
                                                       colorPalletAnnotation2,
                                                       colorPalletAnnotation3])
        return pallet
    }()
    
    
    lazy var cache: [ColorPalletID : ColorPallet] = [colorPallet.id!: colorPallet]
    
    private var palletList: [ColorPallet] {
        cache.values.map {$0 as ColorPallet}
    }
    
    private init() {}
    
    func getColorPalletList(completion: ([ColorPallet]) -> Void) {
        completion(palletList)
    }
    
    func insertColorPallet(title: String,
                           image: UIImage,
                           completion: (ColorPallet?) -> Void) {
        let data = image.compressData()!
        if palletList.isEmpty {
            let id = ColorPalletID()
            let path = Self.saveImage(folderName: id.folderName(), fileName: id.filename(), pngData: data)
            let pallet = ColorPallet.make(id: id,
                                          title: title,
                                          imagePath: path,
                                          annotationList: [])
            cache[id] = pallet
            completion(pallet)
            return
        }
        let nextID = palletList.last!.id!.makeNextID()
        let path = Self.saveImage(folderName: nextID.folderName(), fileName: nextID.filename(), pngData: data)
        let pallet = ColorPallet.make(id: nextID,
                                      title: title,
                                      imagePath: path,
                                      annotationList: [])
        cache[nextID] = pallet
        completion(pallet)
        notifyChanged()
    }
    
    func updateColorPallet(id: ColorPalletID, title: String, image: UIImage, completion: (ColorPallet?) -> Void) {
        guard let pallet = cache[id],
            let data = image.compressData() else {
            completion(nil)
            return
        }
        pallet.title = title
        let path = Self.saveImage(folderName: id.folderName(), fileName: id.filename(), pngData: data)
        pallet.imagePath = path
        cache[id] = pallet
        completion(pallet)
        notifyChanged()
    }
    
    func updateAnnotation(id: ColorPalletID, annotation: ColorPalletAnnotation, completion: (ColorPallet?) -> Void) {
        guard let colorPallet = cache[id] else {
            completion(nil)
            return
        }
        if let index = colorPallet.annotationList.firstIndex(where: {
            $0.id == annotation.id
        }) {
            cache[id]?.annotationList[index] = annotation.makeObject()
            completion(cache[id])
            notifyChanged()
        } else {
            completion(nil)
        }
    }
    
    func insertAnnotation(id: ColorPalletID, completion: (ColorPallet?) -> Void) {
        guard let colorPallet = cache[id] else {
            completion(nil)
            return
        }
        let list = colorPallet.annotationList
        if list.isEmpty {
            let annotationID = ColorPalletAnnotationID()
            annotationID.id = 0
            let annotation = ColorPalletAnnotationObject.make(id: annotationID,
                                                   text: annotationID.id.description,
                                                   pointRatioOnImage: .zero)
            cache[id]?.annotationList.append(annotation)
            completion(cache[id]!)
            notifyChanged()
            return
        }
        let annotationID = list.last!.id!.makeNextAnnotationID()
        let annotation = ColorPalletAnnotationObject.make(id: annotationID,
                                                    text: annotationID.id.description,
                                                    pointRatioOnImage: .zero)
        cache[id]?.annotationList.append(annotation)
        completion(cache[id]!)
        
        notifyChanged()
    }
    
    private func notifyChanged() {
        NotificationCenter.default.post(name: .didColorPalletUpdate, object: nil)
    }
}
