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
    
    let imageWidth = CGFloat(300)
    let imageHeight = CGFloat(500)
    
    lazy var imageCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: imageWidth, height: imageHeight)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .red
        collection.isScrollEnabled = false
         
        return collection
    }()
    
    let viewModel: MakeupLogViewModel
    init(log: MakeupLog) {
        self.viewModel = MakeupLogViewModel(log: log)
        super.init(nibName: nil, bundle: nil)
        
        viewModel.didChangeSegment = { path in
            self.imageCollection.selectItem(at: path,
                                            animated: true,
                                            scrollPosition: .left)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray3
        
        view.addSubview(segment)
        viewModel.segmentActionList().forEach {
            segment.insertSegment(action: $0.action, at: $0.index, animated: false)
        }
        segment.selectedSegmentIndex = 0
        
        view.addSubview(imageCollection)
        imageCollection.dataSource = viewModel
        imageCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "id")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let mainFrame = view.frame
        let margin = (mainFrame.width - imageWidth)/2
        let safeAreaInsets = view.safeAreaInsets
        
        imageCollection.frame = CGRect(x: margin,
                                       y: safeAreaInsets.top,
                                       width: imageWidth,
                                       height: imageHeight)
        
        segment.frame = CGRect(x: margin,
                               y: imageCollection.frame.maxY,
                               width: imageWidth, height: 50)
    }
}
