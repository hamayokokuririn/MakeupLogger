//
//  Annotation.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/01/16.
//

import Foundation
import CoreGraphics
import RealmSwift

protocol Annotation {
    associatedtype ID: AnnotationID
    var id: ID? { get }
    var text: String { get }
    var pointRatioOnImage: PointRatio? { get }
}

protocol AnnotationID {
    var id: Int { get }
    func makeNextAnnotationID() -> Self
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


