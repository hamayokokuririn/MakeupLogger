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
        case part(partID: String)
    }
    
    var state: ViewState = .face {
        didSet {
            switch state {
            case .face:
                let path = IndexPath(item: 0, section: 0)
                delegate?.viewModel(self, didChange: state, cellForRowAt: path)
            case .part(let partID):
                repository.getLogList { logList in
                    let log = logList[0]
                    if let part = log.partsList.firstIndex(where: {$0.id == partID}) {
                        let path = IndexPath(item: part.signum() + 1, section: 0)
                        delegate?.viewModel(self, didChange: state, cellForRowAt: path)
                    }
                    
                }
                
            }
        }
    }
    
    weak var delegate: MakeupLogViewModelDelegate? = nil
    
    lazy var tableViewAdapter = CommentListAdapter(delegate: self)
    private let logID: String
    private let repository: MakeupLogRepository
    
    init(logID: String, repository: MakeupLogRepository = MakeupLogRepositoryInMemory.shared) {
        self.logID = logID
        self.repository = repository
        super.init()
        tableViewAdapter.delegate = self
    }
        
    private func appendAnnotation(_ annotation: FaceAnnotation) {
        if case .part(let partID) = self.state {
            self.repository.insertFaceAnnotation(logID: logID,
                                                 partID: partID,
                                                 faceAnnotation: annotation,
                                                 completion: {_ in
                                                    self.state = .part(partID: partID)
                                                 })
        }
    }
    
    func segmentActionList(completion: ([UIAction]) -> Void) {
        var list = [UIAction]()
        let action = UIAction(title: "face",
                              image: nil, identifier: nil, discoverabilityTitle: nil,
                              attributes: .destructive,
                              state: .on) { _ in
            print("face")
            self.state = .face
        }
        list.append(action)
        repository.getLogList { (logList) in
            for part in logList[0].partsList {
                let action = UIAction(title: part.type,
                                      image: nil,
                                      identifier: nil,
                                      discoverabilityTitle: nil,
                                      attributes: .destructive,
                                      state: .off) { _ in
                    print(part.type)
                    self.state = .part(partID: part.id)
                }
                list.append(action)
            }
            completion(list)
        }
    }
    
    private func updateAnnotation(_ annotation: FaceAnnotation) {
        if case .part(let partID) = self.state {
            repository.updateFaceAnnotation(logID: logID,
                                            partID: partID,
                                            faceAnnotation: annotation) {_ in
                self.state = .part(partID: partID)
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
        return repository.logMap[logID]!.partsList.count + 1
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
            image.image = repository.logMap[logID]!.image
            image.frame.size = cell.frame.size
            image.contentMode = .scaleAspectFit
            return cell
        }
        let part = repository.logMap[logID]!.partsList[indexPath.row - 1]
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
        if case .part(let partID) = state,
           let part = repository.logMap[logID]!.partsList.first(where: {$0.id == partID}) {
            return part.annotations
        }
        return []
    }
    
    func commentListAdapter(_ adapter: CommentListAdapter, didSelectCommentCell index: Int) {
        if case .part(let partID) = state,
           let part = repository.logMap[logID]!.partsList.first(where: {$0.id == partID}) {
            delegate?.viewModel(self, didSelect: part.annotations[index])
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
        if case .part(let partID) = state,
           let part = repository.logMap[logID]!.partsList.first(where: {$0.id == partID}),
           var faceAnnotation = part.annotations.first(where: {$0.id == annotationID}) {
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
