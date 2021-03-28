//
//  ColorPallet.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/13.
//

import Foundation
import UIKit

struct ColorPallet {
    let id: ColorPalletID
    var title: String
    var image: UIImage?
    var annotationList: [ColorPalletAnnotation]
    
    struct ColorPalletID: Codable, Hashable {
        private let prefix = "colorpallet"
        private let idNumber: Int
        private var id: String {
            prefix + "-" + idNumber.description
        }
        
        init(idNumber: Int) {
            self.idNumber = idNumber
        }
        
        func makeNextID() -> ColorPalletID {
            ColorPalletID(idNumber: self.idNumber + 1)
        }
    }
}

