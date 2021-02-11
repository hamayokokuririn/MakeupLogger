//
//  ViewModel.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/01/16.
//

import Foundation

protocol ViewModelDelegate: AnyObject {
    func viewModel(_ model: ViewModel, add annotation: Annotation)
}

final class ViewModel {
    weak var delegate: ViewModelDelegate?
    
    let image = "sample_face"
    let adapter: CommentListAdapter
    var annotationList = [Annotation]()
    
    init(annotaionList: [String]) {
        self.adapter = CommentListAdapter(annotaionList: annotaionList)
        adapter.addAction = addAnnotationAction
        adapter.delegate = self
    }
    
    func touchEnded(annotation: Annotation) {
        guard let index = annotationList.firstIndex(where: { first in
            first.id == annotation.id
        }) else {
            return
        }
        annotationList[index] = annotation
    }
    
    private func addAnnotationAction() {
        let idAndText = String(annotationList.count + 1)
        let annotaion = Annotation(id: idAndText,
                                   text: idAndText)
        annotationList.append(annotaion)
        adapter.annotaionList = annotationList.map {
            $0.text
        }
        self.delegate?.viewModel(self, add: annotaion)
    }
    
}

extension ViewModel: CommentListAdapterDelegate {
    func commentListAdapter(_ adapter: CommentListAdapter, didSelectCommentCell index: Int) {
        print("Annotaionをハイライトする")
    }
}
