//
//  MakeupLogViewController.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import UIKit

final class MakeupLogViewController: UIViewController {
    let segment = UISegmentedControl()
    let image = UIImageView()
    
    let viewModel: MakeupLogViewModel
    init(log: MakeupLog) {
        self.viewModel = MakeupLogViewModel(log: log)
        super.init(nibName: nil, bundle: nil)
        
        viewModel.didChangeSegment = { part in
            let vm = FacePartViewModel(part: part)
            let vc = FacePartViewController(viewModel: vm)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray3
        
        view.addSubview(image)
        image.image = viewModel.log.image
        image.contentMode = .scaleAspectFit
        
        view.addSubview(segment)
        
        viewModel.segmentActionList().forEach {
            segment.insertSegment(action: $0.action, at: $0.index, animated: false)
        }
        segment.selectedSegmentIndex = 0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let mainFrame = view.frame
        let imageWidth = CGFloat(300)
        let imageHeight = CGFloat(500)
        let margin = (mainFrame.width - imageWidth)/2
        let safeAreaInsets = view.safeAreaInsets
        image.frame = CGRect(x: margin,
                             y: safeAreaInsets.top,
                             width: imageWidth,
                             height: imageHeight)
        
        segment.frame = CGRect(x: margin,
                               y: image.frame.maxY,
                               width: imageWidth, height: 50)
    }
}
