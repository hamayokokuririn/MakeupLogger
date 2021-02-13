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
    var annotationList = [FaceAnnotation]()
    
    init(annotationList: [FaceAnnotation]) {
        self.adapter = CommentListAdapter(annotaionList: annotationList)
        self.annotationList = annotationList
        adapter.addAction = addAnnotationAction
        adapter.delegate = self
    }
    
    func touchEnded(annotation: FaceAnnotation) {
        guard let index = annotationList.firstIndex(where: { first in
            first == annotation
        }) else {
            return
        }
        annotationList[index] = annotation
    }
    
    private func addAnnotationAction() {
        let idAndText = String(annotationList.count + 1)
        let id = AnnotationID(id: idAndText)
        let annotaion = FaceAnnotation(id: id, text: idAndText)
        annotationList.append(annotaion)
        adapter.annotaionList = annotationList
        self.delegate?.viewModel(self, add: annotaion)
    }
}

extension ViewModel: CommentListAdapterDelegate {
    func commentListAdapter(_ adapter: CommentListAdapter, didSelectCommentCell index: Int) {
        print("Annotaionをハイライトする")
    }
}
