//
//  AddNewMakeupLogViewModel.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/03/21.
//

import Foundation
import UIKit

final class AddNewMakeupLogViewModel: NSObject {
    enum ValidateError: Error {
        case titleMissing
        case imageMissing
    }
    
    enum TextFieldType: Int {
        case title
        case body
    }
    
    private let repository: MakeupLogRepository
    private var title: String?
    private var body: String?
    var image: UIImage?
    
    var completeAction: (() -> Void)?
    
    init(repository: MakeupLogRepository) {
        self.repository = repository
    }
    
    func addLog() throws {
        guard let title = title else {
            throw ValidateError.titleMissing
        }
        guard let image = image else {
            throw ValidateError.imageMissing
        }
        repository.insertMakeupLog(title: title,
                                   body: body,
                                   image: image) {_ in
            self.completeAction?()
        }
    }
}

extension AddNewMakeupLogViewModel: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let type = TextFieldType(rawValue: textField.tag) else {
            return
        }
        switch type {
        case .title:
            title = textField.text
        case .body:
            body = textField.text
        }
    }
    
}
