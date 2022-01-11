//
//  AnnotationDetailViewController.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/14.
//

import Foundation
import UIKit

final class AnnotationDetailViewController: UIViewController {
    var viewModel: AnnotationDetailViewModel
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var selectedColorPalletName: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    private var colorPalletImage = AnnotationMoveImageView<AnnotationDetailViewController>()
    
    @IBOutlet weak var changeColorPalletButton: UIButton!
    
    init(logID: MakeupLogID, facePartID: FacePartID, annotation: FaceAnnotation, makeupLogRepository: MakeupLogRepository, colorPalletRepository: ColorPalletRepository) {
        self.viewModel = AnnotationDetailViewModel(logID: logID, facePartID: facePartID, annotation: annotation, makeupLogRepository: makeupLogRepository, colorPalletRepository: colorPalletRepository)
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .white
        
        titleText.text = annotation.title
        
        commentTextView.text = annotation.comment
        commentTextView.delegate = self
        
        colorPalletImage.isUserInteractionEnabled = true
        colorPalletImage.movesSubviews = false
        colorPalletImage.delegate = self
        
        colorPalletImage.frame.size = imageView.bounds.size
        colorPalletImage.contentMode = .scaleAspectFit
        colorPalletImage.backgroundColor = .black
        imageView.isUserInteractionEnabled = true
        imageView.addSubview(colorPalletImage)
        
        changeColorPalletButton.addTarget(self, action: #selector(didPushChangeColorPalletButton), for: .touchUpInside)
        
        viewModel.getColorPallet() { pallet in
            setupColorPallet(colorPallet: pallet)
        }
        
        viewModel.didFinishUpdateColorPallet = { colorPallet in
            self.setupColorPallet(colorPallet: colorPallet)
        }
        
        viewModel.didFinishUpdateAnnotation = { text in
            self.titleText.text = text
        }
        
        configureObserver()
    }
    
    // MARK: キーボードでスクロール変更
    //キーボードの出現でスクロールビューを変更するのを監視用オブザーバー
    private func configureObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        //ここでUIKeyboardWillShowという名前の通知のイベントをオブザーバー登録をしている
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        //ここでUIKeyboardWillHideという名前の通知のイベントをオブザーバー登録をしている
    }
    
    //UIKeyboardWillShow通知を受けて、実行される関数
    @objc func keyboardWillShow(_ notification: NSNotification){
        guard let userInfo = notification.userInfo else { return }
        let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        scrollView.contentInset.bottom = keyboardSize
    }
    
    
    //UIKeyboardWillHide通知を受けて、実行される関数
    @objc func keyboardWillHide(_ notification: NSNotification){
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupColorPallet(colorPallet: ColorPallet) {
        selectedColorPalletName.text = colorPallet.title
        if let path = colorPallet.imagePath,
           let data = ColorPalletRealmRepository.imageData(imagePath: path) {
            colorPalletImage.image = UIImage(data: data)
        }
        var annotations = [ColorPalletAnnotationObject]()
        colorPallet.annotationList.forEach {
            annotations.append($0)
        }
        colorPalletImage.addAnnotations(annotations)
        DispatchQueue.main.async {
            let selectedColorPalletAnnotationID = self.viewModel.annotation.selectedColorPalletAnnotationID
            self.colorPalletImage.activateAnnotation(for: selectedColorPalletAnnotationID)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didPushChangeColorPalletButton() {
        let vc = MakeupLogListViewController(mode: .selectColorPallet,
                                             makeupLogRepository: viewModel.makeupLogRepository,
                                             colorPalletRepository: viewModel.colorPalletRepository)
        vc.viewModel.didSelectColorPallet = { colorPallet in
            self.viewModel.updateSelectedColorPallet(colorPallet: colorPallet)
            self.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AnnotationDetailViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.setTitle(textField.text ?? "") 
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension AnnotationDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let text = textView.text else {return}
        viewModel.setComment(text)
    }
    
}

extension AnnotationDetailViewController: AnnotationMoveImageViewDelegate {
    typealias AnnotationType = ColorPalletAnnotationObject
    
    func annotationMoveImageView(_ view: AnnotationMoveImageView<AnnotationDetailViewController>, didTouched annotationViewFrame: CGRect, and id: AnnotationType.ID) {
        viewModel.updateSelectedAnnotation(id: id)
        colorPalletImage.activateAnnotation(for: id)
    }
}
