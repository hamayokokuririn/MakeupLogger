//
//  CommentListAdapter.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/01/15.
//

import Foundation
import UIKit

protocol CommentListAdapterDelegate: AnyObject {
    func commentListAdapter(_ adapter: CommentListAdapter, didSelectCommentCell index: Int)
}

final class CommentListAdapter: NSObject, UITableViewDataSource {
    weak var delegate: CommentListAdapterDelegate?
    
    var annotaionList: [FaceAnnotation]
    
    var addAction: Optional<() -> Void> = nil
    
    init(annotaionList: [FaceAnnotation]) {
        self.annotaionList = annotaionList
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        annotaionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let annotaion = annotaionList[indexPath.row]
        let cell = CommentCell()
        cell.setAnnotationText(annotaion.text)
        cell.setAnnotationComment("test!!")
        return cell
    }
        
}

extension CommentListAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let index = indexPath.row
        delegate?.commentListAdapter(self, didSelectCommentCell: index)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIButton()
        footer.setTitle("add annotation",
                        for: .normal)
        footer.backgroundColor = .green
        footer.frame.size = CGSize(width: tableView.frame.width,
                                   height: 20)
        
        let image = UIImage(systemName: "plus.bubble.fill")
        footer.setImage(image, for: .normal)
        footer.tintColor = .white
        footer.addTarget(self,
                         action: #selector(didPushAdd),
                         for: .touchUpInside)
        return footer
    }
    
    @objc private func didPushAdd() {
        addAction?()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
}
