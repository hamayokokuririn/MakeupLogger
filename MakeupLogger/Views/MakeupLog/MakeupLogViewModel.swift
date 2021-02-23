//
//  MakeupLogViewModel.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import UIKit

protocol MakeupLogViewModelDelegate: AnyObject {
    func viewModel(_ model: MakeupLogViewModel, add annotation: FaceAnnotation)
    func viewModel(_ model: MakeupLogViewModel, didSelect annotation: FaceAnnotation)
    func viewModel(_ model: MakeupLogViewModel, didChange state: MakeupLogViewModel.ViewState, cellForRowAt indexPath: IndexPath)
}

final class MakeupLogViewModel: NSObject {
    enum ViewState: Equatable {
        static func == (lhs: MakeupLogViewModel.ViewState, rhs: MakeupLogViewModel.ViewState) -> Bool {
            switch lhs {
            case .face:
                switch rhs {
                case .face:
                    return true
                case .part(_):
                    return false
                }
            case .part(let lPart):
                switch rhs {
                case .face:
                    return false
                case .part(let rPart):
                    return lPart.type == rPart.type
                }
            }
        }
        
        case face
        case part(FacePart)
    }
    
    var state: ViewState = .face {
        didSet {
            switch state {
            case .face:
                let path = IndexPath(item: 0, section: 0)
                delegate?.viewModel(self, didChange: state, cellForRowAt: path)
            case .part(let facePart):
                self.tableViewAdapter.annotationList = facePart.annotations
                if let index = log.partsList.firstIndex(where: {$0 == facePart}) {
                    let path = IndexPath(item: index.signum() + 1, section: 0)
                    delegate?.viewModel(self, didChange: state, cellForRowAt: path)
                }
            }
        }
    }
    
    weak var delegate: MakeupLogViewModelDelegate? = nil
    
    var log: MakeupLog
    let tableViewAdapter = CommentListAdapter(annotationList: [])
    
    init(log: MakeupLog) {
        self.log = log
        super.init()
        tableViewAdapter.delegate = self
    }
    
    private func appendAnnotation(_ annotation: FaceAnnotation) {
        if case .part(let part) = self.state {
            if let id = log.partsList.firstIndex(where: {
                $0.type == part.type
            }) {
                self.log.partsList[id].annotations.append(annotation)
                self.state = .part(self.log.partsList[id])
            }
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
                let logPart = self.log.partsList[index]
                self.state = .part(logPart)
            }
            list.append((action: action, index: indexPlus1))
        }
        return list
    }
    
    private func updateAnnotation(_ annotation: FaceAnnotation) {
        if case .part(let part) = self.state {
            if let id = log.partsList.firstIndex(where: {
                $0.type == part.type
            }) {
                if let i = self.log.partsList[id].annotations.firstIndex(where: {$0.id == annotation.id}) {
                    log.partsList[id].annotations[i] = annotation
                    self.state = .part(log.partsList[id])
                }
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
    func commentListAdapter(_ adapter: CommentListAdapter, didSelectCommentCell index: Int) {
        let annotation = adapter.annotationList[index]
        delegate?.viewModel(self, didSelect: annotation)
    }
    
    func commentListAdapter(_ adapter: CommentListAdapter, didPushAddButton insertIndex: Int) {
        let idAndText = insertIndex.description
        let annotation = FaceAnnotation(id: idAndText,
                                        text: idAndText,
                                        selectedColorPalletAnnotationID: "1")
        self.appendAnnotation(annotation)
        self.delegate?.viewModel(self, add: annotation)
    }
}

extension MakeupLogViewModel: AnnotationMoveImageViewDelegate {
    func annotationMoveImageView(_ view: AnnotationMoveImageView, didTouched annotationView: AnnotationView) {
        let annotationID = annotationView.annotation.id
        if case .part(let part) = state,
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
