//
//  ColorPalletRepositoryInMemory.swift
//  MakeupLogger
//
//  Created by kengo-saito on 2022/01/04.
//

import Foundation
import UIKit

class ColorPalletRepositoryInMemory: ColorPalletRepository {
    static let shared = ColorPalletRepositoryInMemory()
    
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
    lazy var colorPalletId: ColorPalletID = {
        let id = ColorPalletID()
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
        let id = ColorPalletID()
        let path = Self.saveImage(folderName: id.folderName(), fileName: id.filename(), pngData: data)
        let pallet = ColorPallet.make(id: id,
                                      title: title,
                                      imagePath: path,
                                      annotationList: [])
        cache[id] = pallet
        completion(pallet)
        notifyChanged()
    }
    
    func updateColorPallet(id: ColorPalletID, title: String, image: UIImage, annotations: [ColorPalletAnnotation], completion: (ColorPallet?) -> Void) {
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
        let annotationID = ColorPalletAnnotationID()
        let annotation = ColorPalletAnnotationObject.make(id: annotationID,
                                                          text: annotationID.id.description,
                                                          pointRatioOnImage: .zero,
                                                          title: "")
        cache[id]?.annotationList.append(annotation)
        completion(cache[id]!)
        notifyChanged()
    }
    
    private func notifyChanged() {
        NotificationCenter.default.post(name: .didColorPalletUpdate, object: nil)
    }
    
    func delete(id: ColorPalletID) {
        cache.removeValue(forKey: id)
    }
}
