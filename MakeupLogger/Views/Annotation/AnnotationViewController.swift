//
//  AnnotationViewController.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/01/09.
//

import UIKit

class AnnotationViewController: UIViewController {

    let viewModel: AnnotationViewModel
    lazy var image = UIImage(named: viewModel.image)
    lazy var faceView: AnnotaionMoveImageView = {
        let view = AnnotaionMoveImageView(image: image)
        view.isUserInteractionEnabled = true
        return view
    }()
        
    let tableView = UITableView()
    
    init(viewModel: AnnotationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        viewModel.delegate = self

        let item = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takeNewPhoto))
        self.navigationItem.rightBarButtonItem = item
    }
    
    @objc private func takeNewPhoto() {
        let alert = UIAlertController(title: "画像を変更",
                                      message: nil,
                                      preferredStyle: .alert)
        let cameraAction = UIAlertAction(title: "カメラで撮影",
                                        style: .default) { _ in
            self.camera()
        }
        alert.addAction(cameraAction)
        
        let photoLibraryAction = UIAlertAction(title: "ライブラリから選択",
                                               style: .default) { _ in
            self.photoLibrary()
        }
        alert.addAction(photoLibraryAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func camera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    private func photoLibrary() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.navigationBar.tintColor = .white
        picker.navigationBar.barTintColor = .gray
        present(picker, animated: true, completion: nil)
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

extension AnnotationViewController: AnnotationViewModelDelegate {
    func viewModel(_ model: AnnotationViewModel, add annotation: FaceAnnotation) {
        addAnnotaion(annotation)
        tableView.reloadData()
        let row = tableView.numberOfRows(inSection: 0)
        tableView.scrollToRow(at: IndexPath(row: row - 1, section: 0), at: .bottom, animated: true)
    }
    
    func viewModel(_ model: AnnotationViewModel, didSelect annotation: FaceAnnotation) {
        let vc = AnnotationDetailViewController(annotation: annotation)
        vc.presentationController?.delegate = self
        present(vc, animated: true, completion: nil)
    }
}

extension AnnotationViewController: AnnotaionMoveImageViewDelegate {
    func annotaionMoveImageView(_ view: AnnotaionMoveImageView, touchEnded annotation: Annotation) {
        guard let faceAnnotation = annotation as? FaceAnnotation else {
            return
        }
        viewModel.touchEnded(annotation: faceAnnotation)
    }
}

extension AnnotationViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            faceView.image = image
        } else {
            print("error")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension AnnotationViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        guard let vc = presentationController.presentedViewController as? AnnotationDetailViewController else {
            return
        }
        let annotation = vc.viewModel.annotation
        viewModel.editAnnotation(annotation)
        tableView.reloadData()
    }
}
