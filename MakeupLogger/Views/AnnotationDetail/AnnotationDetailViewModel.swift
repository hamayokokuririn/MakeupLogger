//
//  AnnotationDetailViewModel.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/14.
//

import Foundation

struct AnnotationDetailViewModel {
    var annotation: FaceAnnotation
    
    mutating func setComment(_ text: String) {
        annotation.comment = Comment(text: text)
    }
}
