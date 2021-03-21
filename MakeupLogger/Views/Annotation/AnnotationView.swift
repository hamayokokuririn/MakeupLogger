//
//  AnnotationView.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/11.
//

import Foundation
import UIKit

class AnnotationView<A: Annotation>: UILabel {
    let annotation: A
    init(annotation: A) {
        self.annotation = annotation
        super.init(frame: .zero)
        
        backgroundColor = .red
        frame.size = CGSize(width: 40, height: 40)
        layer.cornerRadius = 20
        clipsToBounds = true
        text = annotation.text
        textColor = .white
        font = .boldSystemFont(ofSize: 24)
        textAlignment = .center
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
