//
//  AddNewColorPalletViewModel.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/04/04.
//

import Foundation
import UIKit

final class AddNewColorPalletViewModel: NSObject {
    enum ValidateError: Error {
        case titleMissing
    }
    
    private let repository: ColorPalletRepository
    private var title: String?
    var image: UIImage?
    
    var completeAction: (() -> Void)?
    
    init(repository: ColorPalletRepository) {
        self.repository = repository
    }
    
    func addLog() throws {
        guard let title = title else {
            throw ValidateError.titleMissing
        }
        repository.insertColorPallet(title: title,
                                     image: image) { _ in
            self.completeAction?()
        }
    }
}

extension AddNewColorPalletViewModel: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        title = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
