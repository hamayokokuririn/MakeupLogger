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
    
    static func make(id: ColorPalletID, title: String, image: Data?, annotationList: [ColorPalletAnnotation]) -> ColorPallet {
        let pallet = ColorPallet()
        pallet.id = id
        pallet.title = title
        pallet.image = image
        let list = List<ColorPalletAnnotation>()
        annotationList.forEach {
            list.append($0)
        }
        pallet.annotationList = list
        return pallet
    }
    
    
    @objc dynamic var id: ColorPalletID? = nil
    @objc dynamic var title: String = ""
    @objc dynamic var image: Data? = nil
    var annotationList = List<ColorPalletAnnotation>()
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let pallet = object as? ColorPallet else {
            return false
        }
        return pallet.id == self.id
    }
    
}

class ColorPalletID: Object, Codable {
    @objc dynamic var id: Int = 0
    
    override init() {
        super.init()
    }
    
    func makeNextID() -> ColorPalletID {
        let id = ColorPalletID()
        id.id = self.id + 1
        return id
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let objectID = object as? ColorPalletID else {
            return false
        }
        return self.id == objectID.id
    }
}

