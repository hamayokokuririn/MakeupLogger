//
//  ColorPallet.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/13.
//

import Foundation
import RealmSwift

class ColorPallet: Object {
    override init() {
        super.init()
    }
    
    static func make(id: ColorPalletID, title: String, imagePath: String, annotationList: [ColorPalletAnnotationObject]) -> ColorPallet {
        let pallet = ColorPallet()
        pallet.id = id
        pallet.title = title
        pallet.imagePath = imagePath
        let list = List<ColorPalletAnnotationObject>()
        annotationList.forEach {
            list.append($0)
        }
        pallet.annotationList = list
        return pallet
    }
    
    
    @objc dynamic var id: ColorPalletID? = nil
    @objc dynamic var title: String = ""
    @objc dynamic var imagePath: String = ""
    @objc dynamic var createAt = Date()
    var annotationList = List<ColorPalletAnnotationObject>()
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let pallet = object as? ColorPallet else {
            return false
        }
        return pallet.id == self.id
    }
    
}

class ColorPalletID: Object, Codable {
    @objc dynamic var id: String = UUID().uuidString
    
    override init() {
        super.init()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let objectID = object as? ColorPalletID else {
            return false
        }
        return self.id == objectID.id
    }
    
    func folderName() -> String {
        "colorpallet"
    }
    
    func filename() -> String {
        id.description + ".png"
    }
}

