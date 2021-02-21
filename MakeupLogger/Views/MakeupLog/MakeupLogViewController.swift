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
    
    let tableView = UITableView()
    let alert = TakePhotoAlert()
    
    let viewModel: MakeupLogViewModel
    init(log: MakeupLog) {
        self.viewModel = MakeupLogViewModel(log: log)
        super.init(nibName: nil, bundle: nil)
        
        viewModel.delegate = self
        viewModel.state = .face
        
        let item = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takeNewPhoto))
        self.navigationItem.rightBarButtonItem = item
    }
    
    @objc private func takeNewPhoto() {
        alert.selectPhotoAction = { image in
            print("写真を追加")
        }
        alert.show(presenter: self)
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
        
        view.addSubview(tableView)
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
                               width: imageWidth, height: 30)
        
        let tableViewTop = segment.frame.maxY + CGFloat(4)
        let tableViewHeight = mainFrame.height - tableViewTop - view.safeAreaInsets.bottom
        tableView.frame = CGRect(x: margin,
                                 y: tableViewTop,
                                 width: imageWidth,
                                 height: tableViewHeight)
    }
}

extension MakeupLogViewController: MakeupLogViewModelDelegate {
    func viewModel(_ model: MakeupLogViewModel, didChange state: MakeupLogViewModel.ViewState) {
        switch state {
        case .face:
            tableView.isHidden = true
            let path = IndexPath(item: 0, section: 0)
            self.imageCollection.selectItem(at: path,
                                            animated: true,
                                            scrollPosition: .left)
        case .part(let facePart):
            tableView.isHidden = false
            if let index = viewModel.log.partsList.firstIndex(where: {$0 == facePart}) {
                let path = IndexPath(item: index.signum() + 1, section: 0)
                self.imageCollection.selectItem(at: path,
                                                animated: true,
                                                scrollPosition: .left)
                self.tableView.delegate = self.viewModel.tableViewAdapter
                self.tableView.dataSource = self.viewModel.tableViewAdapter
                self.tableView.reloadData()
            }
        }
    }
    
    func viewModel(_ model: MakeupLogViewModel, add annotation: FaceAnnotation) {
        imageCollection.reloadData()
        tableView.reloadData()
        let row = tableView.numberOfRows(inSection: 0)
        tableView.scrollToRow(at: IndexPath(row: row - 1, section: 0), at: .bottom, animated: true)
    }
    
    func viewModel(_ model: MakeupLogViewModel, didSelect annotation: FaceAnnotation) {
        let vc = AnnotationDetailViewController(annotation: annotation)
        let navigation = UINavigationController(rootViewController: vc)
        navigation.presentationController?.delegate = self
        present(navigation, animated: true, completion: nil)
    }
    
}

extension MakeupLogViewController: AnnotationMoveImageViewDelegate {
    func annotationMoveImageView(_ view: AnnotationMoveImageView, touchEnded annotation: Annotation) {
        guard let faceAnnotation = annotation as? FaceAnnotation else {
            return
        }
        viewModel.touchEnded(annotation: faceAnnotation)
    }
}

extension MakeupLogViewController: UIAdaptivePresentationControllerDelegate {
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
