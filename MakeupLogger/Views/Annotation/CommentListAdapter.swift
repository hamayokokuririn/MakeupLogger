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
    func commentListAdapter(_ adapter: CommentListAdapter, didDeleteAt index: Int)
    func commentListAdapterAnnotationList(_ adapter: CommentListAdapter) -> [FaceAnnotationObject]
}

final class CommentListAdapter: NSObject, UITableViewDataSource {
    weak var delegate: CommentListAdapterDelegate?
    let colorPalletRepository: ColorPalletRepository
    
    init(delegate: CommentListAdapterDelegate, repository: ColorPalletRepository) {
        self.delegate = delegate
        self.colorPalletRepository = repository
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let delegate = delegate else {return 0}
        return delegate.commentListAdapterAnnotationList(self).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let delegate = delegate else {return UITableViewCell()}
        let annotation = delegate.commentListAdapterAnnotationList(self)[indexPath.row]
        let cell = CommentCell()
        cell.setAnnotationText(annotation.text)
        colorPalletRepository.getColorPalletList { list in
            if let pallet = list.first(where: {$0.id == annotation.selectedColorPalletID}),
               let annotation = pallet.annotationList.first(where: {$0.id == annotation.selectedColorPalletAnnotationID}) {
                cell.setAnnotationComment(annotation.title)
                if let imagePath = pallet.imagePath,
                   let data = ColorPalletRealmRepository.imageData(imagePath: imagePath),
                   let image = UIImage(data: data) {
                    cell.setImage(image)
                }
            }
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
        let footer: UIButton = {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "plus.bubble.fill")
            config.buttonSize = .large

            let button = UIButton(configuration: config)
            button.setTitle("アノテーションを追加", for: .normal)
            button.setTitleColor(.systemBlue, for: .normal)
            return button
        }()
        
        footer.addTarget(self,
                         action: #selector(didPushAdd),
                         for: .touchUpInside)
        return footer
    }
    
    @objc private func didPushAdd() {
        guard let delegate = delegate else {return}
        delegate.commentListAdapter(self, didPushAddButton: delegate.commentListAdapterAnnotationList(self).count + 1)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        42
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .none:
            break
        case .delete:
            delegate?.commentListAdapter(self, didDeleteAt: indexPath.row)
        case .insert:
            break
        @unknown default:
            break
        }
    }
}
