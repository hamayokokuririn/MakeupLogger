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
    
    private let commentTitle: UILabel = .init()
    private let textView: UITextView = .init()
    private let selectedColorPalletTitle: UILabel = .init()
    private let selectedColorPalletAnnotation: UILabel = .init()
    private lazy var colorPalletImage: AnnotationMoveImageView = {
        return AnnotationMoveImageView<AnnotationDetailViewController>()
    }()
        
    private let changeColorPalletButton: UIButton = .init()
    
    init(annotation: FaceAnnotation) {
        self.viewModel = AnnotationDetailViewModel(annotation: annotation)
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
        
        view.addSubview(commentTitle)
        commentTitle.text = "Comment"
        
        view.addSubview(textView)
        textView.text = annotation.comment?.text
        textView.backgroundColor = .systemGray6
        textView.delegate = self
        textView.returnKeyType = .done
        
        view.addSubview(selectedColorPalletTitle)
        selectedColorPalletTitle.text = annotation.colorPallet?.title
        
        view.addSubview(selectedColorPalletAnnotation)
        selectedColorPalletAnnotation.text = annotation.colorPallet?.annotationList.filter {
            $0.id == annotation.selectedColorPalletAnnotationID
        }.first?.text
        
        view.addSubview(colorPalletImage)
        colorPalletImage.backgroundColor = .black
        colorPalletImage.image = annotation.colorPallet?.image
        colorPalletImage.contentMode = .scaleAspectFit
        annotation.colorPallet?.annotationList.forEach {
            let view = AnnotationView(annotation: $0)
            colorPalletImage.addSubview(view)
        }
        
        view.addSubview(changeColorPalletButton)
        changeColorPalletButton.setTitle("Change Color", for: .normal)
        changeColorPalletButton.addTarget(self, action: #selector(didPushChangeColorPalletButton), for: .touchUpInside)
        changeColorPalletButton.setTitleColor(.systemBlue, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let safeAreaInsets = view.safeAreaInsets
        let margin = CGFloat(16) + safeAreaInsets.left
        commentTitle.sizeToFit()
        commentTitle.frame.origin = CGPoint(x: margin, y: safeAreaInsets.top + CGFloat(32))
        textView.frame = CGRect(x: margin,
                                y: commentTitle.frame.maxY,
                                width: view.frame.width,
                                height: 100)
        
        selectedColorPalletTitle.sizeToFit()
        selectedColorPalletTitle.frame.origin = CGPoint(x: margin, y: textView.frame.maxY + CGFloat(8))
        
        selectedColorPalletAnnotation.sizeToFit()
        selectedColorPalletAnnotation.frame.origin = CGPoint(x: margin, y: selectedColorPalletTitle.frame.maxY + CGFloat(8))
        
        colorPalletImage.frame.size = CGSize(width: view.frame.width - margin * 2, height: 300)
        colorPalletImage.frame.origin = CGPoint(x: margin, y: selectedColorPalletAnnotation.frame.maxY + CGFloat(8))
        colorPalletImage.adjustAnnotationViewFrame()
        
        changeColorPalletButton.sizeToFit()
        changeColorPalletButton.frame.origin = CGPoint(x: margin, y: colorPalletImage.frame.maxY + CGFloat(8))
    }
    
    @objc private func didPushChangeColorPalletButton() {
        print("カラーパレットの選択")
    }
    
    @objc private func close() {
        guard let pc = navigationController?.presentationController else {return}
        pc.delegate?.presentationControllerDidDismiss?(pc)
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
    typealias AnnotationType = ColorPalletAnnotation
    
    func annotationMoveImageView(_ view: AnnotationMoveImageView<AnnotationDetailViewController>, didTouched annotationViewFrame: CGRect, and id: AnnotationID) {
        
    }
}
