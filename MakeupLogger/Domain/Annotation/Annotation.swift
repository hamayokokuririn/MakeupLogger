//
//  Annotation.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/01/16.
//

import Foundation
import RealmSwift

protocol Annotation {
    associatedtype ID: AnnotationID
    var id: ID? { get }
    var text: String { get }
    var pointRatioOnImage: PointRatio? { get }
}

protocol AnnotationID {
    var id: Int { get }
    func makeNextAnnotationID() -> Self
}

