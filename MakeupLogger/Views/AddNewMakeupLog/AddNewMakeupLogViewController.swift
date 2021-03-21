//
//  AddNewMakeupLogViewController.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/03/21.
//

import Foundation
import UIKit

/// タイトルと写真を選択する
final class AddNewMakeupLogViewController: UIViewController {
    let titleTextField = UITextField()
    let bodyTextField = UITextField()
    let selectPhotoButton = UIButton()
    let selectedPhotoImage = UIImageView()
    let completeButton = UIButton()
    
    let alert = TakePhotoAlert()
    let viewModel: AddNewMakeupLogViewModel
    
    init(repository: MakeupLogRepository) {
        viewModel = AddNewMakeupLogViewModel(repository: repository)
        super.init(nibName: nil, bundle: nil)
        viewModel.completeAction = {
            // 閉じる
            guard let pc = self.navigationController?.presentationController else {return}
            pc.delegate?.presentationControllerDidDismiss?(pc)
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
        titleTextField.backgroundColor = .white
        titleTextField.delegate = viewModel
        titleTextField.tag = AddNewMakeupLogViewModel.TextFieldType.title.rawValue
        
        view.addSubview(bodyTextField)
        bodyTextField.placeholder = "説明"
        bodyTextField.backgroundColor = .white
        bodyTextField.delegate = viewModel
        bodyTextField.tag = AddNewMakeupLogViewModel.TextFieldType.body.rawValue
        
        view.addSubview(selectPhotoButton)
        selectPhotoButton.setTitle("写真選択", for: .normal)
        selectPhotoButton.addTarget(self, action: #selector(didPushSelectPhoto), for: .touchUpInside)
        
        view.addSubview(selectedPhotoImage)
        selectedPhotoImage.backgroundColor = .black
        
        view.addSubview(completeButton)
        completeButton.setTitle("完了", for: .normal)
        completeButton.addTarget(self, action: #selector(didPushComplete), for: .touchUpInside)
        
        title = "新規ログを追加"
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let margin = CGFloat(8)
        let viewWidth = view.frame.width
        guard let barY = navigationController?.navigationBar.frame.maxY else {
            return
        }
        titleTextField.frame = CGRect(x: 0, y: barY + margin, width: viewWidth, height: 30)
        bodyTextField.frame = CGRect(x: 0, y: titleTextField.frame.maxY + margin, width: viewWidth, height: 30)
        
        selectPhotoButton.sizeToFit()
        selectPhotoButton.frame.origin = CGPoint(x: 0, y: bodyTextField.frame.maxY + margin)
        
        selectedPhotoImage.frame = CGRect(x: 0, y: selectPhotoButton.frame.maxY + margin, width: viewWidth, height: 300)
        
        completeButton.sizeToFit()
        completeButton.frame.origin = CGPoint(x: 0, y: selectedPhotoImage.frame.maxY + margin)
    }
    
    @objc private func didPushSelectPhoto() {
        alert.selectPhotoAction = {[weak self] image in
            // 写真選択時処理
            self?.selectedPhotoImage.image = image
            self?.viewModel.image = image
        }
        alert.show(presenter: self)
    }
    
    @objc private func didPushComplete() {
        do {
            try viewModel.addLog()
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
