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
    private let textField: UITextField = .init()
    private let colorPalletButton: UIButton = .init()
    
    init(annotation: FaceAnnotation) {
        self.viewModel = AnnotationDetailViewModel(annotation: annotation)
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .white
        
        view.addSubview(textField)
        textField.text = annotation.comment?.text
        textField.backgroundColor = .systemGray6
        textField.delegate = self
        textField.returnKeyType = .done
        
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
        textField.frame = CGRect(x: safeAreaInsets.left,
                                 y: safeAreaInsets.top,
                                 width: view.frame.width,
                                 height: 100)
        colorPalletButton.sizeToFit()
        colorPalletButton.frame.origin = CGPoint(x: safeAreaInsets.left, y: textField.frame.maxY)
    }
    
    @objc private func didPushButton() {
        print("カラーパレットの選択")
    }
}

extension AnnotationDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {return}
        viewModel.setComment(text)
    }
}
