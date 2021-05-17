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

class ColorPalletRealmRepository: ColorPalletRepository {
    
    private var realm: Realm!
    
    static let shared = ColorPalletRealmRepository()
    private init() {
        var config = Realm.Configuration.init()
        config.schemaVersion = 0
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
        let result = realm.objects(ColorPallet.self).map { $0 }
        let array = Array(result)
        let pallet: ColorPallet
        if array.isEmpty {
            let id = ColorPalletID()
            id.id = 0
            pallet = ColorPallet.make(id: id,
                                          title: title,
                                          image: image.pngData()!,
                                          annotationList: [])
            realm.add(pallet)
            completion(pallet)
            notifyChanged()
            return
        } else {
            let nextID = array.last!.id!.makeNextID()
            pallet = ColorPallet.make(id: nextID,
                                          title: title,
                                          image: image.pngData()!,
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
        guard let pallet = cache[id] else {
            completion(nil)
            return
        }
        do {
            try realm.write {
                pallet.title = title
                pallet.image = image.pngData()!
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
                pallet.annotationList[index] = annotation
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
            let annotation = ColorPalletAnnotation.make(id: annotationID,
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
        let annotation = ColorPalletAnnotation.make(id: annotationID,
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
    lazy var colorPalletId: ColorPalletID = {
        let id = ColorPalletID()
        id.id = 0
        return id
    }()
    
    lazy var colorPallet = ColorPallet.make(id: colorPalletId,
                                            title: "color_pallet",
                                            image: UIImage(named: "sample_color_pallet")?.pngData(),
                                            annotationList: [colorPalletAnnotation1,
                                                             colorPalletAnnotation2,
                                                             colorPalletAnnotation3])
    
    
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
        if palletList.isEmpty {
            let id = ColorPalletID()
            id.id = 0
            let pallet = ColorPallet.make(id: id,
                                          title: title,
                                          image: image.pngData()!,
                                          annotationList: [])
            cache[id] = pallet
            completion(pallet)
            return
        }
        let nextID = palletList.last!.id!.makeNextID()
        let pallet = ColorPallet.make(id: nextID,
                                      title: title,
                                      image: image.pngData()!,
                                      annotationList: [])
        cache[nextID] = pallet
        completion(pallet)
        notifyChanged()
    }
    
    func updateColorPallet(id: ColorPalletID, title: String, image: UIImage, completion: (ColorPallet?) -> Void) {
        guard let pallet = cache[id] else {
            completion(nil)
            return
        }
        pallet.title = title
        pallet.image = image.pngData()!
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
            cache[id]?.annotationList[index] = annotation
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
            let annotation = ColorPalletAnnotation.make(id: annotationID,
                                                   text: annotationID.id.description,
                                                   pointRatioOnImage: .zero)
            cache[id]?.annotationList.append(annotation)
            completion(cache[id]!)
            notifyChanged()
            return
        }
        let annotationID = list.last!.id!.makeNextAnnotationID()
        let annotation = ColorPalletAnnotation.make(id: annotationID,
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
