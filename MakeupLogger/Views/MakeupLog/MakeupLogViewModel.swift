//
//  MakeupLogViewModel.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import UIKit

protocol MakeupLogViewModelDelegate: AnyObject {
    func viewModelAddAnnotation(_ model: MakeupLogViewModel)
    func viewModel(_ model: MakeupLogViewModel, didSelect annotation: FaceAnnotation)
    func viewModel(_ model: MakeupLogViewModel, didChange state: MakeupLogViewModel.ViewState, cellForRowAt indexPath: IndexPath)
}

final class MakeupLogViewModel: NSObject {
    enum ViewState {
        case face
        case part(partIndex: Int)
    }
    
    var state: ViewState = .face {
        didSet {
            switch state {
            case .face:
                let path = IndexPath(item: 0, section: 0)
                delegate?.viewModel(self, didChange: state, cellForRowAt: path)
            case .part(let index):
                let path = IndexPath(item: index + 1, section: 0)
                delegate?.viewModel(self, didChange: state, cellForRowAt: path)
            }
        }
    }
    
    weak var delegate: MakeupLogViewModelDelegate? = nil
    
    var log: MakeupLog
    lazy var tableViewAdapter = CommentListAdapter(delegate: self)
    
    init(log: MakeupLog) {
        self.log = log
        super.init()
        tableViewAdapter.delegate = self
    }
    
    private func appendAnnotation(_ annotation: FaceAnnotation) {
        if case .part(let index) = self.state {
            self.log.partsList[index].annotations.append(annotation)
            self.state = .part(partIndex: index)
        }
    }
    
    func segmentActionList() -> [(action: UIAction, index: Int)] {
        var list = [(action: UIAction, index: Int)]()
        let action = UIAction(title: "face",
                              image: nil, identifier: nil, discoverabilityTitle: nil,
                              attributes: .destructive,
                              state: .on) { _ in
            print("face")
            self.state = .face
        }
        list.append((action: action, index: 0))
        for (index, part) in log.partsList.enumerated() {
            let indexPlus1 = index + 1
            let action = UIAction(title: part.type,
                                  image: nil,
                                  identifier: nil,
                                  discoverabilityTitle: nil,
                                  attributes: .destructive,
                                  state: .off) { _ in
                print(part.type)
                self.state = .part(partIndex: index)
            }
            list.append((action: action, index: indexPlus1))
        }
        return list
    }
    
    private func updateAnnotation(_ annotation: FaceAnnotation) {
        if case .part(let index) = self.state {
            if let i = self.log.partsList[index].annotations.firstIndex(where: {$0.id == annotation.id}) {
                log.partsList[index].annotations[i] = annotation
                self.state = .part(partIndex: index)
            }
        }
    }
    
    func touchEnded(annotation: FaceAnnotation) {
        updateAnnotation(annotation)
    }
    
    func editAnnotation(_ annotation: FaceAnnotation) {
        updateAnnotation(annotation)
    }
}

extension MakeupLogViewModel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return log.partsList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "id",
                                                      for: indexPath)
        cell.backgroundColor = .green
        cell.contentView.subviews.forEach {
            $0.removeFromSuperview()
        }
        if indexPath.row == 0 {
            let image = UIImageView()
            cell.contentView.addSubview(image)
            image.image = log.image
            image.frame.size = cell.frame.size
            image.contentMode = .scaleAspectFit
            return cell
        }
        let part = log.partsList[indexPath.row - 1]
        let view = AnnotationMoveImageView(image: part.image)
        view.isUserInteractionEnabled = true
        view.frame.size = cell.frame.size
        view.contentMode = .scaleAspectFit
        part.annotations.forEach {
            let annotation = AnnotationView(annotation: $0)
            view.addSubview(annotation)
        }
        view.adjustAnnotationViewFrame()
        view.delegate = self
        cell.contentView.addSubview(view)
        cell.contentView.isUserInteractionEnabled = true
        return cell
    }
    
}

extension MakeupLogViewModel: CommentListAdapterDelegate {
    func commentListAdapterAnnotationList(_ adapter: CommentListAdapter) -> [FaceAnnotation] {
        if case .part(let index) = state {
            return log.partsList[index].annotations
        }
        return []
    }
    
    func commentListAdapter(_ adapter: CommentListAdapter, didSelectCommentCell index: Int) {
        if case .part(let partIndex) = state {
            delegate?.viewModel(self, didSelect: log.partsList[partIndex].annotations[index])
        }
        return
    }
    
    func commentListAdapter(_ adapter: CommentListAdapter, didPushAddButton insertIndex: Int) {
        let idAndText = insertIndex.description
        let annotation = FaceAnnotation(id: idAndText,
                                        text: idAndText,
                                        selectedColorPalletAnnotationID: "1")
        self.appendAnnotation(annotation)
        self.delegate?.viewModelAddAnnotation(self)
    }
}

extension MakeupLogViewModel: AnnotationMoveImageViewDelegate {
    func annotationMoveImageView(_ view: AnnotationMoveImageView, didTouched annotationView: AnnotationView) {
        let annotationID = annotationView.annotation.id
        if case .part(let index) = state,
           var faceAnnotation = log.partsList[index].annotations.first(where: {$0.id == annotationID}) {
            let imageViewRect = view.imageRect()
            let point = CGPoint(x: annotationView.frame.minX - imageViewRect.minX,
                                y: annotationView.frame.minY - imageViewRect.minY)
            let pointRatio = PointRatio(parentViewSize: imageViewRect.size,
                                        annotationPoint: point)
            faceAnnotation.pointRatioOnImage = pointRatio
            touchEnded(annotation: faceAnnotation)
        }
    }
    
}

extension MakeupLogViewModel.ViewState: Equatable {
    static func == (lhs: MakeupLogViewModel.ViewState, rhs: MakeupLogViewModel.ViewState) -> Bool {
        switch lhs {
        case .face:
            switch rhs {
            case .face:
                return true
            case .part(_):
                return false
            }
        case .part(let lIndex):
            switch rhs {
            case .face:
                return false
            case .part(let rIndex):
                return lIndex == rIndex
            }
        }
    }
}
