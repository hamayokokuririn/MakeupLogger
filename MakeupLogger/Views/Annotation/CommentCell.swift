//
//  CommentCell.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/13.
//

import Foundation
import UIKit

final class CommentCell: UITableViewCell {
    var didEndEditing: ((String) -> Void)?
    
    let idLabel: UILabel = .init()
    let commentField: UITextField = .init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(idLabel)
        idLabel.textAlignment = .center
        
        contentView.addSubview(commentField)
        commentField.delegate = self
        commentField.returnKeyType = .done
        commentField.backgroundColor = .systemGray6
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = frame.height
        idLabel.frame = CGRect(x: 0, y: 0, width: 30, height: height)
        commentField.frame = CGRect(x: idLabel.frame.maxX,
                                    y: 0,
                                    width: frame.width - idLabel.frame.width,
                                    height: height)
    }
    
    func setAnnotationText(_ text: String) {
        idLabel.text = text
    }
    
    func setAnnotationComment(_ text: String) {
        commentField.text = text
    }
}

extension CommentCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {return}
        self.didEndEditing?(text)
    }
}
