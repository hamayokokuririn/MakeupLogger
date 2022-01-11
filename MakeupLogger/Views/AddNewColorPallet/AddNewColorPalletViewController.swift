//
//  AddNewColorPalletViewController.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/04/04.
//

import Foundation
import UIKit

final class AddNewColorPalletViewController: UIViewController {
    let titleTextField = UITextField()
    let selectPhotoButton = UIButton()
    let selectedPhotoImage = UIImageView()
    let completeButton = UIButton()
    
    let alert = TakePhotoAlert()
    let viewModel: AddNewColorPalletViewModel
    
    init(repository: ColorPalletRepository) {
        viewModel = AddNewColorPalletViewModel(repository: repository)
        super.init(nibName: nil, bundle: nil)
        viewModel.completeAction = { [weak self] in
            // 閉じる
            self?.navigationController?.popViewController(animated: true)
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
        titleTextField.returnKeyType = .done
        
        view.addSubview(selectPhotoButton)
        selectPhotoButton.setTitle("写真選択", for: .normal)
        selectPhotoButton.addTarget(self, action: #selector(didPushSelectPhoto), for: .touchUpInside)
        
        view.addSubview(selectedPhotoImage)
        selectedPhotoImage.contentMode = .scaleAspectFit
        selectedPhotoImage.backgroundColor = .black
        
        view.addSubview(completeButton)
        completeButton.setTitle("完了", for: .normal)
        completeButton.addTarget(self, action: #selector(didPushComplete), for: .touchUpInside)
        
        title = "新規カラーパレットを追加"
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
        
        selectedPhotoImage.frame = CGRect(x: 0, y: selectPhotoButton.frame.maxY + margin, width: viewWidth, height: 300)
        
        completeButton.sizeToFit()
        completeButton.frame.origin = CGPoint(x: 0, y: selectedPhotoImage.frame.maxY + margin)
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
