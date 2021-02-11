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
        adapter.addAction = {
            self.addAnnotation()
        }
    }
    
    private func addAnnotation() {
        let annotaion = Annotation(id: "1",
                                   text: "1")
        annotaionList.append(annotaion)
        delegate?.viewModel(self, add: annotaion)
    }
}
