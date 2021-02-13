//
//  ViewController.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/01/09.
//

import UIKit

class ViewController: UIViewController {

    let viewModel: ViewModel
    lazy var image = UIImage(named: viewModel.image)
    lazy var faceView: AnnotaionMoveImageView = {
        let view = AnnotaionMoveImageView(image: image)
        view.isUserInteractionEnabled = true
        return view
    }()
        
    let tableView = UITableView()
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray3
        view.addSubview(faceView)
        view.addSubview(tableView)
        
        faceView.backgroundColor = .black
        faceView.contentMode = .scaleAspectFit
        faceView.delegate = self
        
        tableView.dataSource = viewModel.adapter
        tableView.delegate = viewModel.adapter
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let mainFrame = view.frame
        let imageWidth = CGFloat(300)
        let imageHeight = CGFloat(500)
        let margin = (mainFrame.width - imageWidth)/2
        let safeAreaInsets = view.safeAreaInsets
        faceView.frame = CGRect(x: margin,
                                y: safeAreaInsets.top,
                                width: imageWidth,
                                height: imageHeight)
        
        let tableViewTop = faceView.frame.maxY + CGFloat(24)
        let tableViewHeight = mainFrame.height - tableViewTop - view.safeAreaInsets.bottom
        tableView.frame = CGRect(x: margin,
                                 y: tableViewTop,
                                 width: imageWidth,
                                 height: tableViewHeight)
    }

        
    func addAnnotaion(_ annotation: Annotation) {
        let view = AnnotationView(annotation: annotation)
        faceView.addSubview(view)
    }
}

extension ViewController: ViewModelDelegate {
    func viewModel(_ model: ViewModel, add annotation: FaceAnnotation) {
        addAnnotaion(annotation)
        tableView.reloadData()
    }
    
}

extension ViewController: AnnotaionMoveImageViewDelegate {
    func annotaionMoveImageView(_ view: AnnotaionMoveImageView, touchEnded annotation: Annotation) {
        guard let faceAnnotation = annotation as? FaceAnnotation else {
            return
        }
        viewModel.touchEnded(annotation: faceAnnotation)
    }
}
