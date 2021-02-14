//
//  ColorPallet.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/13.
//

import Foundation
import UIKit

struct ColorPallet: Codable {
    let id: ColorPalletID
    var title: String
    var imageFileName: String
    var annotationList: [ColorPalletAnnotation]
    
    struct ColorPalletID: Codable {
        let id: String
    }
}

struct ColorPalletAnnotation: Annotation {
    let id: String
    let text: String
    var pointRatioOnImage: PointRatio
}
