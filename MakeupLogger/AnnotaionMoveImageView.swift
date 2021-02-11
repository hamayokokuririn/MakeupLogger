//
//  AnnotaionMoveImageView.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/11.
//

import Foundation
import UIKit

class AnnotaionMoveImageView: UIImageView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("Began")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        print("ended")
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
}
