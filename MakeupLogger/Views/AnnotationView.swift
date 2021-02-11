//
//  AnnotationView.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/11.
//

import Foundation
import UIKit

class AnnotationView: UILabel {
    let annotation: Annotation
    init(annotation: Annotation) {
        self.annotation = annotation
        super.init(frame: .zero)
        
        backgroundColor = .red
        frame.size = CGSize(width: 40, height: 40)
        text = annotation.text
        textColor = .white
        textAlignment = .center
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
