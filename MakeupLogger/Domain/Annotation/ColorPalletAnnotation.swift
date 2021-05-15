//
//  ColorPalletAnnotation.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import RealmSwift

class ColorPalletAnnotation: Object, Annotation {
    override init() {
        super.init()
    }
    
    static func make(id: ColorPalletAnnotationID, text: String, pointRatioOnImage: PointRatio) -> ColorPalletAnnotation {
        let annotation = ColorPalletAnnotation()
        annotation.id = id
        annotation.text = text
        annotation.pointRatioOnImage = pointRatioOnImage
        return annotation
    }
    
    typealias ID = ColorPalletAnnotationID

    @objc dynamic var id: ColorPalletAnnotationID?
    @objc dynamic var text: String = ""
    @objc dynamic var pointRatioOnImage: PointRatio? = .zero
    
}

class ColorPalletAnnotationID: Object, AnnotationID, Codable {
    @objc dynamic var id: Int = 0
    func makeNextAnnotationID() -> Self {
        let id = ColorPalletAnnotationID()
        id.id = self.id + 1
        return id as! Self
    }
}
