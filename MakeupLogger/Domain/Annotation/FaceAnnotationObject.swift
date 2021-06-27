//
//  FaceAnnotation.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import RealmSwift
import CoreGraphics

class FaceAnnotation {
    init(id: FaceAnnotationID, text: String = "", pointRatioOnImage: PointRatio = .zero, comment: String? = nil, selectedColorPalletID: ColorPalletID? = nil, selectedColorPalletAnnotationID: ColorPalletAnnotationID? = nil) {
        self.id = id
        self.text = text
        self.pointRatioOnImage = pointRatioOnImage
        self.comment = comment
        self.selectedColorPalletID = selectedColorPalletID
        self.selectedColorPalletAnnotationID = selectedColorPalletAnnotationID
    }
    
    let id: FaceAnnotationID
    var text: String = ""
    var pointRatioOnImage: PointRatio = .zero
    var comment: String? = nil
    var selectedColorPalletID: ColorPalletID? {
        didSet {
            self.selectedColorPalletAnnotationID = nil
        }
    }
    var selectedColorPalletAnnotationID: ColorPalletAnnotationID? = nil
    
    func makeObject() -> FaceAnnotationObject {
        let object = FaceAnnotationObject()
        object.id = id
        object.text = text
        object.pointRatioOnImage = pointRatioOnImage
        object.comment = comment
        object.selectedColorPalletID = selectedColorPalletID
        object.selectedColorPalletAnnotationID = selectedColorPalletAnnotationID
        return object
    }
}

class FaceAnnotationObject: Object, Annotation {
    override init() {
        super.init()
    }
    
    typealias ID = FaceAnnotationID
    @objc dynamic var id: FaceAnnotationID = FaceAnnotationID()
    @objc dynamic var text: String = ""
    @objc dynamic var pointRatioOnImage: PointRatio = .zero
    @objc dynamic var comment: String? = nil
    @objc dynamic var selectedColorPalletID: ColorPalletID? {
        didSet {
            self.selectedColorPalletAnnotationID = nil
        }
    }
    var selectedColorPalletAnnotationID: ColorPalletAnnotationID? = nil
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let annotation = object as? FaceAnnotationObject else {
            return false
        }
        return self.id == annotation.id
    }
    
    func makeAnnotation() -> FaceAnnotation {
        return FaceAnnotation(id: id, text: text, pointRatioOnImage: pointRatioOnImage, comment: comment, selectedColorPalletID: selectedColorPalletID, selectedColorPalletAnnotationID: selectedColorPalletAnnotationID)
    }
    
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
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let objectID = object as? FaceAnnotationID else {
            return false
        }
        return self.id == objectID.id
    }
}

class PointRatio: Object, Codable {
    @objc dynamic var x: Float = 0
    @objc dynamic var y: Float = 0
    
    static var zero: PointRatio {
        return PointRatio()
    }
        
    override init() {
        super.init()
    }
    
    static func make(parentViewSize: CGSize, annotationPoint: CGPoint) -> PointRatio {
        let ratio = PointRatio()
        ratio.x = Float(annotationPoint.x / parentViewSize.width)
        ratio.y = Float(annotationPoint.y / parentViewSize.height)
        return ratio
    }
}
