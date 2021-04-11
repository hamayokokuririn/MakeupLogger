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
    associatedtype AnnotationType: Annotation
    func annotationMoveImageView(_ view: AnnotationMoveImageView<Self>, didTouched annotationViewFrame: CGRect, and id: AnnotationID)
}

class AnnotationMoveImageView<D: AnnotationMoveImageViewDelegate>: UIImageView {
    weak var delegate: D?
    
    var movesSubviews: Bool = true
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("Began")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let view = touches.first?.view as? AnnotationView<D.AnnotationType> else {
            return
        }
        
        delegate?.annotationMoveImageView(self,
                                          didTouched: view.frame, and: view.annotation.id)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first,
              let view = touch.view,
              movesSubviews else {
            return
        }
        if view != self {
            view.center = touch.location(in: self)
        }
    }
    
    func adjustAnnotationViewFrame() {
        subviews.compactMap {
            $0 as? AnnotationView<D.AnnotationType>
        }.forEach {
            let imageRect = self.imageRect()
            $0.frame.origin = CGPoint(x: CGFloat($0.annotation.pointRatioOnImage.x) * imageRect.width + imageRect.minX,
                                      y: CGFloat($0.annotation.pointRatioOnImage.y) * imageRect.height + imageRect.minY)
        }
    }
    
    func imageRect() -> CGRect {
        return AVMakeRect(aspectRatio: image!.size, insideRect: bounds)
    }
    
    func activateAnnotation(for id: D.AnnotationType.ID?) {
        guard let annotationViews = subviews as? [AnnotationView<D.AnnotationType>] else {
            return
        }
        annotationViews.forEach {
            $0.backgroundColor = .black
        }
        if let id = id,
           let view = annotationViews.first(where: {
            $0.annotation.id.id == id.id
        }) {
            view.backgroundColor = .green
        }
    }
    
}
