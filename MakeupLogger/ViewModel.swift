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

class ViewModel {
    weak var delegate: ViewModelDelegate?
    
    let image = "sample_face"
    let adapter: CommentListAdapter
    var annotaionList = [Annotation]()
    
    init(annotaionList: [String]) {
        self.adapter = CommentListAdapter(annotaionList: annotaionList)
        adapter.addAction = addAnnotationAction
        adapter.delegate = self
    }
    
    private func addAnnotationAction() {
        let idAndText = String(annotaionList.count + 1)
        let annotaion = Annotation(id: idAndText,
                                   text: idAndText)
        annotaionList.append(annotaion)
        adapter.annotaionList = annotaionList.map {
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
