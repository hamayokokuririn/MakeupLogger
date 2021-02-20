//
//  Annotation.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/01/16.
//

import Foundation
import CoreGraphics

protocol Annotation: Codable {
    var id: String { get }
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


