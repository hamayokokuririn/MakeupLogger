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
        case part(partID: FacePartID)
    }
    
    var state: ViewState = .face {
        didSet {
            switch state {
            case .face:
                let path = IndexPath(item: 0, section: 0)
                delegate?.viewModel(self, didChange: state, cellForRowAt: path)
            case .part(let partID):
                makeupLogRepository.getLogList { logList in
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
    let logID: MakeupLogID
    let makeupLogRepository: MakeupLogRepository
    let colorPalletRepository: ColorPalletRepository
    
    
    init(logID: MakeupLogID,
         makeupLogRepository: MakeupLogRepository,
         colorPalletRepository: ColorPalletRepository) {
        self.logID = logID
        self.makeupLogRepository = makeupLogRepository
        self.colorPalletRepository = colorPalletRepository
        super.init()
        tableViewAdapter.delegate = self
    }
        
    private func appendAnnotation() {
        if case .part(let partID) = self.state {
            self.makeupLogRepository.insertFaceAnnotation(logID: logID,
                                                 partID: partID,
                                                 completion: {_ in
                                                    self.state = .part(partID: partID)
                                                 })
        }
    }
    
    func segmentActionList(completion: ([UIAction]) -> Void) {
        var list = [UIAction]()
        let action = UIAction(title: "1",
                              image: nil, identifier: nil, discoverabilityTitle: nil,
                              attributes: .destructive,
                              state: .on) { _ in
            print("face")
            self.state = .face
        }
        list.append(action)
        makeupLogRepository.getLogList { (logList) in
            guard let log = logList.first(where: {
                $0.id == logID
            }) else {return}
            for part in log.partsList {
                let action = UIAction(title: (part.id!.id + 1).description,
                                      image: nil,
                                      identifier: nil,
                                      discoverabilityTitle: nil,
                                      attributes: .destructive,
                                      state: .off) { _ in
                    print(part.type)
                    self.state = .part(partID: part.id!)
                }
                list.append(action)
            }
            completion(list)
        }
    }
    
    private func updateAnnotation(_ annotation: FaceAnnotation) {
        if case .part(let partID) = self.state {
            makeupLogRepository.updateFaceAnnotation(logID: logID,
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
    
    func addPicture(type: String, image: UIImage) {
        makeupLogRepository.insertFacePart(logID: logID, type: type, image: image) { (log) in
            guard let log = log else {
                print(#function + "画像追加失敗")
                return
            }
            self.state = .part(partID: log.partsList.last!.id!)
        }
    }
}

extension MakeupLogViewModel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return makeupLogRepository.logMap[logID]!.partsList.count + 1
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "id",
                                                      for: indexPath)
        cell.backgroundColor = .white
        cell.contentView.subviews.forEach {
            $0.removeFromSuperview()
        }
        if indexPath.row == 0 {
            let image = UIImageView()
            cell.contentView.addSubview(image)
            image.image = UIImage(data: makeupLogRepository.logMap[logID]!.imagePath!)
            image.frame.size = cell.frame.size
            image.contentMode = .scaleAspectFit
            return cell
        }
        let part = makeupLogRepository.logMap[logID]!.partsList[indexPath.row - 1]
        let view = AnnotationMoveImageView<Self>(image: UIImage(data: part.image!)!)
        view.isUserInteractionEnabled = true
        view.frame.size = cell.frame.size
        view.contentMode = .scaleAspectFit
        part.annotations.forEach {
            let annotation = AnnotationView(annotation: $0)
            view.addSubview(annotation)
        }
        view.adjustAnnotationViewFrame()
        view.delegate = self as? Self
        cell.contentView.addSubview(view)
        cell.contentView.isUserInteractionEnabled = true
        return cell
    }
    
}

extension MakeupLogViewModel: CommentListAdapterDelegate {
    func commentListAdapterAnnotationList(_ adapter: CommentListAdapter) -> [FaceAnnotation] {
        if case .part(let partID) = state,
           let part = makeupLogRepository.logMap[logID]!.partsList.first(where: {$0.id == partID}) {
            var annotations = [FaceAnnotation]()
            part.annotations.forEach {
                annotations.append($0)
            }
            return annotations
        }
        return []
    }
    
    func commentListAdapter(_ adapter: CommentListAdapter, didSelectCommentCell index: Int) {
        if case .part(let partID) = state,
           let part = makeupLogRepository.logMap[logID]!.partsList.first(where: {$0.id == partID}) {
            delegate?.viewModel(self, didSelect: part.annotations[index])
        }
        return
    }
    
    func commentListAdapter(_ adapter: CommentListAdapter, didPushAddButton insertIndex: Int) {
        self.appendAnnotation()
        self.delegate?.viewModelAddAnnotation(self)
    }
}

extension MakeupLogViewModel: AnnotationMoveImageViewDelegate {
    typealias AnnotationType = FaceAnnotation
    
    func annotationMoveImageView(_ view: AnnotationMoveImageView<MakeupLogViewModel>, didTouched annotationViewFrame: CGRect, and id: AnnotationID) {
        if case .part(let partID) = state,
           let part = makeupLogRepository.logMap[logID]!.partsList.first(where: {$0.id == partID}),
           let faceID = id as? FaceAnnotationID,
           let faceAnnotation = part.annotations.first(where: {$0.id == faceID}) {
            let imageViewRect = view.imageRect()
            let point = CGPoint(x: annotationViewFrame.minX - imageViewRect.minX,
                                y: annotationViewFrame.minY - imageViewRect.minY)
            let pointRatio = PointRatio.make(parentViewSize: imageViewRect.size,
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
