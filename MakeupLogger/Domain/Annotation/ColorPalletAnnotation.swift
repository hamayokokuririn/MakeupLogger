//
//  ColorPalletAnnotation.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation

struct ColorPalletAnnotation: Annotation {
    typealias ID = CPID

    var id: CPID
    let text: String
    var pointRatioOnImage: PointRatio
    
    struct CPID: AnnotationID, Equatable, Codable {
        var id: Int = 0
        
        func makeNextAnnotationID() -> CPID {
            CPID(id: id + 1)
        }
    }
}
