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
    var partsList: [FacePart]
}

struct FacePart: Equatable, Hashable {
    let id: String
    let type: String
    let image: UIImage
    var annotations: [FaceAnnotation]
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(image.description)
        annotations.forEach {
            hasher.combine($0.id)
        }
    }

}
