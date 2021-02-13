//
//  ViewModel.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/01/16.
//

import Foundation

protocol ViewModelDelegate: AnyObject {
    func viewModel(_ model: ViewModel, add annotation: FaceAnnotation)
}

final class ViewModel {
    weak var delegate: ViewModelDelegate?
    
    let image = "sample_face"
    let adapter: CommentListAdapter
    
    init(annotationList: [FaceAnnotation]) {
        self.adapter = CommentListAdapter(annotationList: annotationList)
        adapter.addAction = addAnnotationAction
        adapter.delegate = self
    }
    
    func touchEnded(annotation: FaceAnnotation) {
        guard let index = adapter.annotationList.firstIndex(where: { first in
            first == annotation
        }) else {
            return
        }
        adapter.annotationList[index] = annotation
    }
    
    private func addAnnotationAction() {
        let idAndText = String(adapter.annotationList.count + 1)
        let id = AnnotationID(id: idAndText)
        let annotaion = FaceAnnotation(id: id, text: idAndText)
        adapter.annotationList.append(annotaion)
        self.delegate?.viewModel(self, add: annotaion)
    }
}

extension ViewModel: CommentListAdapterDelegate {
    func commentListAdapter(_ adapter: CommentListAdapter, didSelectCommentCell index: Int) {
        print("Annotaionをハイライトする")
    }
}
