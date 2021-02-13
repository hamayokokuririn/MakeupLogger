//
//  ColorPallet.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/13.
//

import Foundation
import UIKit

struct ColorPallet: Codable {
    let faceAnnotationID: FaceAnnotation.FaceAnnotationID
    var imageFileName: String
    var annotationList: [ColorPalletAnnotation]
}

struct ColorPalletAnnotation: Annotation {
    var id: AnnotationID
    let text: String
    var pointRatioOnImage: PointRatio
    
    struct CollorPalletAnnotationID: Codable {
        let id: String
    }
}
