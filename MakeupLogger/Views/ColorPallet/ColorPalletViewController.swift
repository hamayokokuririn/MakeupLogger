//
//  ColorPalletViewController.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/04/04.
//

import Foundation
import UIKit

final class ColorPalletViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var selectPhotoButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addAnnotationButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let selectedPhotoImage = AnnotationMoveImageView<ColorPalletViewController>()
    
    let alert = TakePhotoAlert()
    let viewModel: ColorPalletViewModel
    
    init(colorPallet: ColorPallet, repository: ColorPalletRepository) {
        viewModel = ColorPalletViewModel(colorPalletID: colorPallet.id!,
                                         repository: repository)
        super.init(nibName: nil, bundle: nil)
        viewModel.completeAction = {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "カラーパレットを編集"
        let item = UIBarButtonItem(barButtonSystemItem: .save,
                                   target: self,
                                   action: #selector(didPushComplete))
        self.navigationItem.rightBarButtonItem = item
        
        titleTextField.placeholder = "タイトル"
        titleTextField.text = viewModel.title
        titleTextField.backgroundColor = .white
        titleTextField.delegate = viewModel
        titleTextField.returnKeyType = .done
        
        selectPhotoButton.addTarget(self, action: #selector(didPushSelectPhoto), for: .touchUpInside)
        
        imageView.addSubview(selectedPhotoImage)
        imageView.isUserInteractionEnabled = true
        selectedPhotoImage.image = viewModel.image
        selectedPhotoImage.contentMode = .scaleAspectFit
        selectedPhotoImage.backgroundColor = .black
        selectedPhotoImage.delegate = self
        selectedPhotoImage.isUserInteractionEnabled = true
        selectedPhotoImage.addAnnotations(viewModel.annotationList.map {$0.makeObject()})
        
        addAnnotationButton.addTarget(self, action: #selector(didPushAddAnnotation), for: .touchUpInside)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        tableView.dataSource = viewModel
        let nib = UINib(nibName: "ColorPalletAnnotationTableViewCell",
                        bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ColorPalletAnnotationTableViewCell")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        selectedPhotoImage.frame.size = imageView.bounds.size
        selectedPhotoImage.adjustAnnotationViewFrame()
    }
    
    @objc private func didPushSelectPhoto() {
        view.endEditing(true)
        alert.selectPhotoAction = {[weak self] image in
            // 写真選択時処理
            self?.selectedPhotoImage.image = image
            self?.viewModel.image = image
        }
        alert.show(presenter: self)
    }
    
    @objc private func didPushAddAnnotation() {
        viewModel.addAnnotation() { pallet in
            selectedPhotoImage.subviews.forEach {
                $0.removeFromSuperview()
            }
            pallet?.annotationList.forEach {
                let annotation = AnnotationView(annotation: $0)
                selectedPhotoImage.addSubview(annotation)
            }
            selectedPhotoImage.adjustAnnotationViewFrame()
            
            tableView.reloadData()
        }
    }
    
    @objc private func didPushComplete() {
        do {
            try viewModel.complete()
        } catch {
            if let error = error as? ColorPalletViewModel.ValidateError {
                switch error {
                case .titleMissing:
                    // タイトルが不正です
                    titleTextField.backgroundColor = .red
                    return
                }
            }
            
        }
    }
}

extension ColorPalletViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

extension ColorPalletViewController: AnnotationMoveImageViewDelegate {
    typealias AnnotationType = ColorPalletAnnotationObject
    
    func annotationMoveImageView(_ view: AnnotationMoveImageView<ColorPalletViewController>, didTouched annotationViewFrame: CGRect, and id: AnnotationType.ID) {
        
        viewModel.didAnnotationUpdate(view, didTouched: annotationViewFrame, and: id)
    }
}
