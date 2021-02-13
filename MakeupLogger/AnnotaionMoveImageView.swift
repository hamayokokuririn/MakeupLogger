//
//  AnnotaionMoveImageView.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/11.
//

import Foundation
import UIKit

protocol AnnotaionMoveImageViewDelegate: AnyObject {
    func annotaionMoveImageView(_ view: AnnotaionMoveImageView, touchEnded annotation: Annotation)
}

class AnnotaionMoveImageView: UIImageView {
    weak var delegate: AnnotaionMoveImageViewDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("Began")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let view = firstTouchAnnotation(from: touches) else {
            return
        }
        
        delegate?.annotaionMoveImageView(self, touchEnded: view.annotation)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first,
              let view = touch.view else {
            return
        }
        if view != self {
            view.center = touch.location(in: self)
        }
    }
    
    private func firstTouchAnnotation(from touches: Set<UITouch>) -> AnnotationView? {
        guard let touch = touches.first else {
            return nil
        }
        return touch.view as? AnnotationView
    }
}
