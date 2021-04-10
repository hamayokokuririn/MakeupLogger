//
//  ColorPalletViewController.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/04/04.
//

import Foundation
import UIKit

extension ColorPalletViewController: AnnotationMoveImageViewDelegate {
    typealias AnnotationType = ColorPalletAnnotation
    
    func annotationMoveImageView(_ view: AnnotationMoveImageView<ColorPalletViewController>, didTouched annotationViewFrame: CGRect, and id: AnnotationID) {
        
        viewModel.didAnnotationUpdate(view, didTouched: annotationViewFrame, and: id)
    }
}

final class ColorPalletViewController: UIViewController {
    let titleTextField = UITextField()
    let selectPhotoButton = UIButton()
    let selectedPhotoImage = AnnotationMoveImageView<ColorPalletViewController>()
    let addAnnotationButton = UIButton()
    let completeButton = UIButton()
    
    let alert = TakePhotoAlert()
    let viewModel: ColorPalletViewModel
    
    init(colorPallet: ColorPallet, repository: ColorPalletRepository) {
        viewModel = ColorPalletViewModel(colorPalletID: colorPallet.id,
                                         repository: repository)
        super.init(nibName: nil, bundle: nil)
        viewModel.completeAction = {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .systemGray3
        
        view.addSubview(titleTextField)
        titleTextField.placeholder = "タイトル"
        titleTextField.text = viewModel.title
        titleTextField.backgroundColor = .white
        titleTextField.delegate = viewModel
        
        view.addSubview(selectPhotoButton)
        selectPhotoButton.setTitle("画像変更", for: .normal)
        selectPhotoButton.addTarget(self, action: #selector(didPushSelectPhoto), for: .touchUpInside)
        
        view.addSubview(selectedPhotoImage)
        selectedPhotoImage.image = viewModel.image
        selectedPhotoImage.contentMode = .scaleAspectFit
        selectedPhotoImage.backgroundColor = .black
        selectedPhotoImage.delegate = self
        selectedPhotoImage.isUserInteractionEnabled = true
        selectedPhotoImage.contentMode = .scaleAspectFit
        viewModel.annotationList.forEach {
            let annotation = AnnotationView(annotation: $0)
            selectedPhotoImage.addSubview(annotation)
        }
        selectedPhotoImage.adjustAnnotationViewFrame()
        
        view.addSubview(addAnnotationButton)
        addAnnotationButton.setTitle("アノテーション追加", for: .normal)
        addAnnotationButton.addTarget(self, action: #selector(didPushAddAnnotation), for: .touchUpInside)
        
        view.addSubview(completeButton)
        completeButton.setTitle("完了", for: .normal)
        completeButton.addTarget(self, action: #selector(didPushComplete), for: .touchUpInside)
        
        title = "カラーパレットを編集"
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let margin = CGFloat(8)
        let viewWidth = view.frame.width
        guard let barY = navigationController?.navigationBar.frame.maxY else {
            return
        }
        titleTextField.frame = CGRect(x: 0, y: barY + margin, width: viewWidth, height: 30)
        
        selectPhotoButton.sizeToFit()
        selectPhotoButton.frame.origin = CGPoint(x: 0, y: titleTextField.frame.maxY + margin)
        selectedPhotoImage.adjustAnnotationViewFrame()
        
        selectedPhotoImage.frame = CGRect(x: 0, y: selectPhotoButton.frame.maxY + margin, width: viewWidth, height: 300)
        selectedPhotoImage.adjustAnnotationViewFrame()
        
        addAnnotationButton.sizeToFit()
        addAnnotationButton.frame.origin = CGPoint(x: 0, y: selectedPhotoImage.frame.maxY + margin)
        
        completeButton.sizeToFit()
        completeButton.frame.origin = CGPoint(x: 0, y: addAnnotationButton.frame.maxY + margin)
    }
    
    @objc private func didPushSelectPhoto() {
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
        }
    }
    
    @objc private func didPushComplete() {
        do {
            try viewModel.complete()
        } catch {
            if let error = error as? AddNewMakeupLogViewModel.ValidateError {
                switch error {
                case .titleMissing:
                    // タイトルが不正です
                    titleTextField.backgroundColor = .red
                    return
                case .imageMissing:
                    // イメージが不正です
                    selectedPhotoImage.backgroundColor = .red
                    return
                }
            }
            
        }
    }
}
