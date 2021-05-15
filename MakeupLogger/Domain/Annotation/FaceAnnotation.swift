//
//  FaceAnnotation.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import RealmSwift

class FaceAnnotation: Object, Annotation {
    override init() {
        super.init()
    }
    
    typealias ID = FaceAnnotationID
    @objc dynamic var id: FaceAnnotationID? = FaceAnnotationID()
    @objc dynamic var text: String = ""
    @objc dynamic var pointRatioOnImage: PointRatio? = .zero
    @objc dynamic var comment: String? = nil
    @objc dynamic var selectedColorPalletID: ColorPalletID? {
        didSet {
            self.selectedColorPalletAnnotationID = nil
        }
    }
    var selectedColorPalletAnnotationID: ColorPalletAnnotationID? = nil
    
}

class FaceAnnotationID: Object, AnnotationID {
    override init() {
        super.init()
    }
    
    @objc dynamic var id: Int = 0
    func makeNextAnnotationID() -> Self {
        let id = FaceAnnotationID()
        id.id = self.id + 1
        return id as! Self
    }
}
