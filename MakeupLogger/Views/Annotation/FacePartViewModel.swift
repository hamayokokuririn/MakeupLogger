//
//  ViewModel.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/01/16.
//

import Foundation

protocol AnnotationViewModelDelegate: AnyObject {
    func viewModel(_ model: FacePartViewModel, add annotation: FaceAnnotation)
    func viewModel(_ model: FacePartViewModel, didSelect annotation: FaceAnnotation)
}

final class FacePartViewModel {
    weak var delegate: AnnotationViewModelDelegate?
    
    let part: FacePart
    let adapter: CommentListAdapter
    
    init(part: FacePart) {
        self.part = part
        self.adapter = CommentListAdapter(annotationList: part.annotations)
        adapter.delegate = self
    }
    
    func touchEnded(annotation: FaceAnnotation) {
        adapter.updateAnnotation(annotation)
    }
    
    func editAnnotation(_ annotation: FaceAnnotation) {
        adapter.updateAnnotation(annotation)
    }
    
    private func addAnnotationAction() {
        let idAndText = String(adapter.annotationList.count + 1)
        let annotation = FaceAnnotation(id: idAndText, text: idAndText, selectedColorPalletAnnotationID: "1")
        adapter.annotationList.append(annotation)
        self.delegate?.viewModel(self, add: annotation)
    }
}

extension FacePartViewModel: CommentListAdapterDelegate {
    func commentListAdapter(_ adapter: CommentListAdapter, didPushAddButton insertIndex: Int) {
        print("add action")
    }
    func commentListAdapter(_ adapter: CommentListAdapter, didSelectCommentCell index: Int) {
        let annotation = adapter.annotationList[index]
        delegate?.viewModel(self, didSelect: annotation)
    }
}
