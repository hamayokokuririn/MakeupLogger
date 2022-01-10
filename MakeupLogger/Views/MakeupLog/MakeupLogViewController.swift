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
        collection.isScrollEnabled = false
         
        return collection
    }()
    
    let tableView = UITableView()
    
    let alert = TakePhotoAlert()
    let viewModel: MakeupLogViewModel
    
    init(log: MakeupLog,
         makeupLogRepository: MakeupLogRepository,
         colorPalletRepository: ColorPalletRepository) {
        self.viewModel = MakeupLogViewModel(log: log,
                                            makeupLogRepository: makeupLogRepository,
                                            colorPalletRepository: colorPalletRepository)
        super.init(nibName: nil, bundle: nil)
        
        viewModel.delegate = self
        
        let item = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(takeNewPhoto))
        self.navigationItem.rightBarButtonItem = item
        
        title = log.title
    }
    
    @objc private func takeNewPhoto() {
        alert.selectPhotoAction = {[weak self] image in
            self?.viewModel.editPicture(image: image)
            self?.imageCollection.reloadData()
        }
        alert.show(presenter: self)
    }
    
    @objc private func updatePhoto() {
        alert.selectPhotoAction = {[weak self] image in
            self?.viewModel.updatePicture(image: image)
        }
        alert.show(presenter: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(segment)
        
        view.addSubview(imageCollection)
        imageCollection.dataSource = viewModel
        imageCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "id")
        
        view.addSubview(tableView)
        tableView.delegate = viewModel.tableViewAdapter
        tableView.dataSource = viewModel.tableViewAdapter
        
        viewModel.state = .face
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
    func viewModel(_ model: MakeupLogViewModel, didChange state: MakeupLogViewModel.ViewState, cellForRowAt indexPath: IndexPath) {
        tableView.isHidden = state == .face
        
        self.imageCollection.reloadData()
        self.imageCollection.selectItem(at: indexPath,
                                        animated: true,
                                        scrollPosition: .left)
        self.tableView.reloadData()
        
        self.reloadSegment()
        segment.selectedSegmentIndex = indexPath.row
    }
    
    private func reloadSegment() {
        segment.removeAllSegments()
        viewModel.segmentActionList { (actions) in
            var index = 0
            actions.forEach {
                segment.insertSegment(action: $0, at: index, animated: false)
                index += 1
            }
        }
        // 設定しないと何も選択されていない状態になる
        segment.selectedSegmentIndex = 0
        viewModel.selectedSegmentIndex { i in
            segment.selectedSegmentIndex = i
        }
    }
    
    func viewModelAddAnnotation(_ model: MakeupLogViewModel) {
        imageCollection.reloadData()
        tableView.reloadData()
        let row = tableView.numberOfRows(inSection: 0)
        guard row > 0 else {return}
        tableView.scrollToRow(at: IndexPath(row: row - 1, section: 0), at: .bottom, animated: true)
    }
    
    func viewModel(_ model: MakeupLogViewModel, didSelect annotation: FaceAnnotation) {
        if case .part(let partID) = viewModel.state {
            let vc = AnnotationDetailViewController(logID: viewModel.log.id!,
                                                    facePartID: partID,
                                                    annotation: annotation,
                                                    makeupLogRepository: viewModel.makeupLogRepository,
                                                    colorPalletRepository: viewModel.colorPalletRepository)
            let navigation = UINavigationController(rootViewController: vc)
            navigation.presentationController?.delegate = self
            present(navigation, animated: true, completion: nil)
        }
    }
    
    func viewModelDidPushNewPhoto(_ model: MakeupLogViewModel) {
        updatePhoto()
    }
    
    func viewModelDeleteAnnotation(_ model: MakeupLogViewModel) {
        tableView.reloadData()
    }
}

extension MakeupLogViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
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
