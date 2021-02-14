//
//  ViewModel.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/01/16.
//

import Foundation

protocol AnnotationViewModelDelegate: AnyObject {
    func viewModel(_ model: AnnotationViewModel, add annotation: FaceAnnotation)
    func viewModel(_ model: AnnotationViewModel, didSelect annotation: FaceAnnotation)
}

final class AnnotationViewModel {
    weak var delegate: AnnotationViewModelDelegate?
    
    let image = "sample_face"
    let adapter: CommentListAdapter
    
    init(annotationList: [FaceAnnotation]) {
        self.adapter = CommentListAdapter(annotationList: annotationList)
        adapter.addAction = addAnnotationAction
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
        let annotaion = FaceAnnotation(id: idAndText, text: idAndText, selectedColorPalletAnnotationID: "1")
        adapter.annotationList.append(annotaion)
        self.delegate?.viewModel(self, add: annotaion)
    }
}

extension AnnotationViewModel: CommentListAdapterDelegate {
    func commentListAdapter(_ adapter: CommentListAdapter, didSelectCommentCell index: Int) {
        let annotation = adapter.annotationList[index]
        delegate?.viewModel(self, didSelect: annotation)
    }
}
