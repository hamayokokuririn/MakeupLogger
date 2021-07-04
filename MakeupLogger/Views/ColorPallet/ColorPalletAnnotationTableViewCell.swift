//
//  ColorPalletAnnotationTableViewCell.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/07/04.
//

import UIKit

protocol ColorPalletAnnotationTableViewCellDelegate : AnyObject {
    func didEnded(_ cell: ColorPalletAnnotationTableViewCell, editing text: String)
}

class ColorPalletAnnotationTableViewCell: UITableViewCell {
    weak var delegate :ColorPalletAnnotationTableViewCellDelegate?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var id: ColorPalletAnnotationID? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.delegate = self
    }

    func setLabel(_ text: String) {
        label.text = text
    }
    
    func setTextTitle(_ text: String) {
        textField.text = text
    }
    
}

extension ColorPalletAnnotationTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.didEnded(self, editing: textField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
