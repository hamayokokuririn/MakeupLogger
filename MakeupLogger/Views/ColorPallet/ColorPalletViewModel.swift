//
//  ColorPalletViewModel.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/04/04.
//

import Foundation
import UIKit

final class ColorPalletViewModel: NSObject {
    enum ValidateError: Error {
        case titleMissing
        case imageMissing
    }
    
    let colorPallet: ColorPallet
    private let repository: ColorPalletRepository
    private var title: String?
    var image: UIImage?
    
    var completeAction: (() -> Void)?
    
    init(colorPallet: ColorPallet, repository: ColorPalletRepository) {
        self.colorPallet = colorPallet
        self.repository = repository
        
        title = colorPallet.title
        image = colorPallet.image
    }
    
    func addAnnotation(completion: (ColorPallet?) -> Void) {
        repository.insertAnnotation(id: colorPallet.id) { pallet in
            completion(pallet)
        }
    }
    
    func complete() throws {
        guard let title = title else {
            throw ValidateError.titleMissing
        }
        guard let image = image else {
            throw ValidateError.imageMissing
        }
        repository.updateColorPallet(id: colorPallet.id,
                                     title: title,
                                     image: image) { _ in
            completeAction?()
        }
    
    }
}

extension ColorPalletViewModel: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        title = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
