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
    func annotationMoveImageView(_ view: AnnotationMoveImageView<Self>, didTouched annotationViewFrame: CGRect, and id: AnnotationType.ID)
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
                                          didTouched: view.frame, and: view.annotation.id!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first,
              let view = touch.view,
              movesSubviews else {
            return
        }
        
        if view != self {
            let location = touch.location(in: self)
            if imageRect().contains(location) {
                view.center = location
            }
        }
    }
    
    func addAnnotations(_ annotations: [D.AnnotationType]) {
        subviews.forEach {
            $0.removeFromSuperview()
        }
        annotations.forEach {
            let view = AnnotationView(annotation: $0)
            addSubview(view)
        }
        adjustAnnotationViewFrame()
    }
    
    func adjustAnnotationViewFrame() {
        subviews.compactMap {
            $0 as? AnnotationView<D.AnnotationType>
        }.forEach {
            let imageRect = self.imageRect()
            let point = $0.annotation.pointRatioOnImage!
            $0.frame.origin = CGPoint(x: CGFloat(point.x) * imageRect.width + imageRect.minX,
                                      y: CGFloat(point.y) * imageRect.height + imageRect.minY)
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
            $0.annotation.id!.id == id.id
        }) {
            view.backgroundColor = .green
        }
    }
    
}
