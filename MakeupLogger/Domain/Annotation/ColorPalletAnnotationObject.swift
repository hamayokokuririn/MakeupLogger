//
//  ColorPalletAnnotation.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import RealmSwift

class ColorPalletAnnotation {
    init(id: ColorPalletAnnotationID,
         text: String,
         title: String,
         pointRatioOnImage: PointRatio = .zero) {
        self.id = id
        self.text = text
        self.title = title
        self.pointRatioOnImage = pointRatioOnImage
    }
    
    var id: ColorPalletAnnotationID
    var text: String
    var title: String
    var pointRatioOnImage: PointRatio = .zero
    
    func makeObject() -> ColorPalletAnnotationObject {
        let object = ColorPalletAnnotationObject()
        object.id = id
        object.text = text
        object.title = title
        object.pointRatioOnImage = pointRatioOnImage
        return object
    }
}

class ColorPalletAnnotationObject: Object, Annotation {
    override init() {
        super.init()
    }
    
    static func make(id: ColorPalletAnnotationID, text: String, pointRatioOnImage: PointRatio, title: String) -> ColorPalletAnnotationObject {
        let annotation = ColorPalletAnnotationObject()
        annotation.id = id
        annotation.text = text
        annotation.title = title
        annotation.pointRatioOnImage = pointRatioOnImage
        return annotation
    }
    
    typealias ID = ColorPalletAnnotationID

    @objc dynamic var id: ColorPalletAnnotationID? = ColorPalletAnnotationID()
    @objc dynamic var text: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var pointRatioOnImage: PointRatio? = .zero
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let annotation = object as? ColorPalletAnnotationObject else {
            return false
        }
        return self.id == annotation.id
    }
    
    func makeAnnotation(point: PointRatio? = nil) -> ColorPalletAnnotation {
        if let point = point {
            return ColorPalletAnnotation(id: id!, text: text, title: title, pointRatioOnImage: point)
        }
        return ColorPalletAnnotation(id: id!, text: text, title: title, pointRatioOnImage: self.pointRatioOnImage!)
    }
}

class ColorPalletAnnotationID: Object, AnnotationID, Codable {
    @objc dynamic var id: String = UUID().uuidString
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let objectID = object as? ColorPalletAnnotationID else {
            return false
        }
        return self.id == objectID.id
    }
}
