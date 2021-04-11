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
    typealias ID = FAID
    var id: FAID
    let text: String
    var pointRatioOnImage: PointRatio = .zero
    var comment: Comment?
    var selectedColorPalletID: ColorPallet.ColorPalletID? {
        didSet {
            self.selectedColorPalletAnnotationID = nil
        }
    }
    var selectedColorPalletAnnotationID: ColorPalletAnnotation.CPID?
    
    struct FAID: AnnotationID, Equatable, Codable {
        var id: Int = 0
        
        func makeNextAnnotationID() -> FAID {
            FAID(id: id + 1)
        }
    }
}
