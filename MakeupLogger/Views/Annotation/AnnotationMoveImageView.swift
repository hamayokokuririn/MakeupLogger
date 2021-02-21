//
//  AnnotationMoveImageView.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/11.
//

import Foundation
import UIKit
import AVFoundation

protocol AnnotationMoveImageViewDelegate: AnyObject {
    func annotationMoveImageView(_ view: AnnotationMoveImageView, touchEnded annotation: Annotation)
}

class AnnotationMoveImageView: UIImageView {
    weak var delegate: AnnotationMoveImageViewDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("Began")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let view = firstTouchAnnotation(from: touches) else {
            return
        }
        
        delegate?.annotationMoveImageView(self, touchEnded: view.annotation)
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
    
    func adjustAnnotationViewFrame() {
        subviews.compactMap {
            $0 as? AnnotationView
        }.forEach {
            let imageRect = self.imageRect()
            $0.frame.origin = CGPoint(x: CGFloat($0.annotation.pointRatioOnImage.x) * imageRect.width + imageRect.minX,
                                      y: CGFloat($0.annotation.pointRatioOnImage.y) * imageRect.height + imageRect.minY)
        }
    }
    
    private func imageRect() -> CGRect {
        return AVMakeRect(aspectRatio: image!.size, insideRect: bounds)
    }
    
    private func firstTouchAnnotation(from touches: Set<UITouch>) -> AnnotationView? {
        guard let touch = touches.first else {
            return nil
        }
        return touch.view as? AnnotationView
    }
}
