//
//  TakePhotoAlert.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/14.
//

import Foundation
import UIKit

class TakePhotoAlert: NSObject {
    var selectPhotoAction: ((UIImage) -> Void)?
    var presenter: UIViewController?

    func show(presenter: UIViewController) {
        self.presenter = presenter
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
        let cancelAction = UIAlertAction(title: "キャンセル",
                                               style: .cancel) { _ in
            self.presenter?.dismiss(animated: false, completion: nil)
        }
        alert.addAction(cancelAction)
        presenter.present(alert, animated: true, completion: nil)
    }
    
    private func camera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        presenter?.present(picker, animated: true, completion: nil)
    }
    
    private func photoLibrary() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.navigationBar.tintColor = .white
        picker.navigationBar.barTintColor = .gray
        presenter?.present(picker, animated: true, completion: nil)
    }
}

extension TakePhotoAlert: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            presenter?.dismiss(animated: true, completion: nil)
            selectPhotoAction?(image)
            return
        }
        presenter?.dismiss(animated: true, completion: nil)
        print("error")
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        presenter?.dismiss(animated: true, completion: nil)
    }
}
