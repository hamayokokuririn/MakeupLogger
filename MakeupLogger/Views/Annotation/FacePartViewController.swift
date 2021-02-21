//
//  AnnotationViewController.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/01/09.
//

import UIKit

class FacePartViewController: UIViewController {

    let viewModel: FacePartViewModel
    let alert: TakePhotoAlert
    
    lazy var faceView: AnnotationMoveImageView = {
        let view = AnnotationMoveImageView(image: viewModel.part.image)
        view.isUserInteractionEnabled = true
        return view
    }()
        
    let tableView = UITableView()
    
    init(viewModel: FacePartViewModel) {
        self.viewModel = viewModel
        self.alert = TakePhotoAlert()
        super.init(nibName: nil, bundle: nil)

        viewModel.delegate = self

        let item = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takeNewPhoto))
        self.navigationItem.rightBarButtonItem = item
    }
    
    @objc private func takeNewPhoto() {
        alert.selectPhotoAction = { image in
            self.faceView.image = image
        }
        alert.show(presenter: self)
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
        viewModel.part.annotations.forEach {
            let view = AnnotationView(annotation: $0)
            faceView.addSubview(view)
        }
        
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
        faceView.adjustAnnotationViewFrame()
        
        let tableViewTop = faceView.frame.maxY + CGFloat(24)
        let tableViewHeight = mainFrame.height - tableViewTop - view.safeAreaInsets.bottom
        tableView.frame = CGRect(x: margin,
                                 y: tableViewTop,
                                 width: imageWidth,
                                 height: tableViewHeight)
    }

        
    func addAnnotation(_ annotation: Annotation) {
        let view = AnnotationView(annotation: annotation)
        faceView.addSubview(view)
    }
}

extension FacePartViewController: AnnotationViewModelDelegate {
    func viewModel(_ model: FacePartViewModel, add annotation: FaceAnnotation) {
        addAnnotation(annotation)
        tableView.reloadData()
        let row = tableView.numberOfRows(inSection: 0)
        tableView.scrollToRow(at: IndexPath(row: row - 1, section: 0), at: .bottom, animated: true)
    }
    
    func viewModel(_ model: FacePartViewModel, didSelect annotation: FaceAnnotation) {
        let vc = AnnotationDetailViewController(annotation: annotation)
        let navigation = UINavigationController(rootViewController: vc)
        navigation.presentationController?.delegate = self
        present(navigation, animated: true, completion: nil)
    }
}

extension FacePartViewController: AnnotationMoveImageViewDelegate {
    func annotationMoveImageView(_ view: AnnotationMoveImageView, didTouched annotationView: AnnotationView) {
        guard let faceAnnotation = annotationView.annotation as? FaceAnnotation else {
            return
        }
        viewModel.touchEnded(annotation: faceAnnotation)
    }
    
}


extension FacePartViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        guard let navi = presentationController.presentedViewController as? UINavigationController,
              let vc = navi.topViewController as? AnnotationDetailViewController else {
            return
        }
        dismiss(animated: true, completion: nil)
        let annotation = vc.viewModel.annotation
        viewModel.editAnnotation(annotation)
        tableView.reloadData()
    }
}
