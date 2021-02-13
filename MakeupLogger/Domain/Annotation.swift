//
//  Annotation.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/01/16.
//

import Foundation
import CoreGraphics

protocol Annotation: Codable {
    var id: AnnotationID { get }
    var text: String { get }
    var pointRatioOnImage: PointRatio { get }
}

struct PointRatio: Codable {
    var x: Float
    var y: Float
    
    static var zero: PointRatio {
        PointRatio(x: 0, y: 0)
    }
    
    init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
    
    init(parentViewSize: CGSize, annotationPoint: CGPoint) {
        self.x = Float(annotationPoint.x / parentViewSize.width)
        self.y = Float(annotationPoint.y / parentViewSize.height)
    }
}

struct AnnotationID: Codable {
    let id: String
}

struct FaceAnnotation: Annotation {
    let id: AnnotationID
    let text: String
    var pointRatioOnImage: PointRatio = .zero
    var comment: Comment?
    var colorPallet: ColorPallet?
    
    struct FaceAnnotationID: Codable {
        let id: String
    }
}

extension FaceAnnotation: Equatable {
    static func == (lhs: FaceAnnotation, rhs: FaceAnnotation) -> Bool {
        lhs.id.id == rhs.id.id
    }
}
