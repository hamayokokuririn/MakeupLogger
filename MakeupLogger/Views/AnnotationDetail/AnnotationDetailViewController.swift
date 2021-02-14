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
    private let colorPalletButton: UIButton = .init()
    
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
        
        view.addSubview(colorPalletButton)
        colorPalletButton.setTitle("Color", for: .normal)
        colorPalletButton.addTarget(self, action: #selector(didPushButton), for: .touchUpInside)
        colorPalletButton.setTitleColor(.systemBlue, for: .normal)
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
        colorPalletButton.sizeToFit()
        colorPalletButton.frame.origin = CGPoint(x: margin, y: textView.frame.maxY + CGFloat(8))
    }
    
    @objc private func didPushButton() {
        print("カラーパレットの選択")
    }
    
    @objc private func close() {
        guard let pc = navigationController?.presentationController else {return}
        pc.delegate?.presentationControllerWillDismiss?(pc)
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
