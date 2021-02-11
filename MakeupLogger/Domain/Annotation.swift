//
//  Annotation.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/01/16.
//

import Foundation
import CoreGraphics

struct Annotation: Codable {
    let id: String
    let text: String
    var point: CGPoint = .zero
}
