//
//  FaceAnnotation.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation

struct FaceAnnotation: Annotation, Equatable {
    static func == (lhs: FaceAnnotation, rhs: FaceAnnotation) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String
    let text: String
    var pointRatioOnImage: PointRatio = .zero
    var comment: Comment?
    var colorPallet: ColorPallet?
    var selectedColorPalletAnnotationID: String?
}
