//
//  CommentCell.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/13.
//

import Foundation
import UIKit

final class CommentCell: UITableViewCell {
    
    let idLabel: UILabel = .init()
    let commentLabel: UILabel = .init()
    let palletImageView: UIImageView = .init(image: nil)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(idLabel)
        idLabel.textAlignment = .center
        
        contentView.addSubview(commentLabel)
        
        contentView.addSubview(palletImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = frame.height
        idLabel.frame = CGRect(x: 0, y: 0, width: 30, height: height)
        palletImageView.frame = CGRect(x: idLabel.frame.maxX,
                                       y: 0,
                                       width: 60,
                                       height: height)
        commentLabel.frame = CGRect(x: palletImageView.frame.maxX,
                                    y: 0,
                                    width:
                                        frame.width
                                    - idLabel.frame.width
                                    - palletImageView.frame.width,
                                    height: height)
    }
    
    func setAnnotationText(_ text: String) {
        idLabel.text = text
    }
    
    func setAnnotationComment(_ text: String) {
        commentLabel.text = text
    }
    
    func setImage(_ image: UIImage) {
        palletImageView.image = image
    }
}

