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
    func commentListAdapter(_ adapter: CommentListAdapter, didPushAddButton insertIndex: Int)
}

final class CommentListAdapter: NSObject, UITableViewDataSource {
    weak var delegate: CommentListAdapterDelegate?
    
    var annotationList: [FaceAnnotation]
    
    init(annotationList: [FaceAnnotation]) {
        self.annotationList = annotationList
    }
    
    func updateAnnotation(_ annotation: FaceAnnotation) {
        guard let index = annotationList.firstIndex(where: { first in
            first == annotation
        }) else {
            return
        }
        annotationList[index] = annotation
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        annotationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let annotation = annotationList[indexPath.row]
        let cell = CommentCell()
        cell.setAnnotationText(annotation.text)
        if let comment = annotation.comment?.text {
            cell.setAnnotationComment(comment)
        }
        cell.didEndEditing = { text in
            let cellAnnotation = self.annotationList[indexPath.row]
            self.annotationList[indexPath.row] = FaceAnnotation(id: cellAnnotation.id,
                                                               text: cellAnnotation.text,
                                                               pointRatioOnImage: cellAnnotation.pointRatioOnImage,
                                                               comment: Comment(text: text),
                                                               colorPallet: cellAnnotation.colorPallet)
        }
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
        delegate?.commentListAdapter(self, didPushAddButton: annotationList.count + 1)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
}
