//
//  MakeupLog.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import UIKit

struct MakeupLog {
    let id: String
    let title: String
    let image: UIImage
    let partsList: [FacePart]
}

struct FacePart {
    let type: String
    let image: UIImage
    let annotations: [FaceAnnotation]
}
