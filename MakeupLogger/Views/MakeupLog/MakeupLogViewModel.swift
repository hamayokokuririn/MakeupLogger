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
    func viewModelDeleteAnnotation(_ model: MakeupLogViewModel)
    func viewModel(_ model: MakeupLogViewModel, didSelect annotation: FaceAnnotation)
    func viewModel(_ model: MakeupLogViewModel, didChange state: MakeupLogViewModel.ViewState, cellForRowAt indexPath: IndexPath)
    func viewModelDidPushNewPhoto(_ model: MakeupLogViewModel)
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
                if let part = self.log.partsList.firstIndex(where: {$0.id == partID}) {
                    let path = IndexPath(item: part + 1, section: 0)
                    delegate?.viewModel(self, didChange: state, cellForRowAt: path)
                }
            }
        }
    }
    
    weak var delegate: MakeupLogViewModelDelegate? = nil
    
    lazy var tableViewAdapter = CommentListAdapter(delegate: self)
    private(set) var log: MakeupLog
    
    let makeupLogRepository: MakeupLogRepository
    let colorPalletRepository: ColorPalletRepository
    
    
    init(log: MakeupLog,
         makeupLogRepository: MakeupLogRepository,
         colorPalletRepository: ColorPalletRepository) {
        self.log = log
        self.makeupLogRepository = makeupLogRepository
        self.colorPalletRepository = colorPalletRepository
        super.init()
        tableViewAdapter.delegate = self
    }
        
    private func appendAnnotation() {
        if case .part(let partID) = self.state {
            self.makeupLogRepository.insertFaceAnnotation(logID: log.id!,
                                                          partID: partID,
                                                          completion: { log in
                guard let log = log else {
                    return
                }
                self.log = log
                self.state = .part(partID: partID)
                
            })
        }
    }
    
    private func deleteAnnotation(index: Int) {
        if case .part(let partID) = self.state {
            if let id = log.partsList.first(where: {$0.id == partID})?.annotations[index].id {
                self.makeupLogRepository.delete(logID: log.id!,
                                                partID: partID,
                                                annotation: id)
            }
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
        makeupLogRepository.getLogList { (logList) in
            guard let log = logList.first(where: {
                $0.id == log.id
            }) else {return}
            for part in log.partsList {
                let action = UIAction(title: part.type,
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
    
    func selectedSegmentIndex(index: (Int) -> Void)  {
        switch state {
        case .face:
            return index(0)
        case .part(let id):
            makeupLogRepository.getLogList { list in
                let i = list.firstIndex { log in
                    log.id == id
                }
                index(i ?? 0)
            }
        }
    }
    
    private func updateAnnotation(_ annotation: FaceAnnotation) {
        if case .part(let partID) = self.state {
            makeupLogRepository.updateFaceAnnotation(logID: log.id!,
                                            partID: partID,
                                                     faceAnnotation: annotation) { log in
                guard let log = log else {
                    return
                }
                self.log = log
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
    
    func editPicture(image: UIImage) {
        switch state {
        case .face:
            if let updated = makeupLogRepository.updateMakeupLog(logID: log.id!, image: image) {
                self.log = updated
            }
        case .part(partID: let partID):
            guard let facePart = log.partsList.first(where: {$0.id == partID}) else {return}
            makeupLogRepository.updateFacePart(logID: log.id!, part: facePart, image: image) { log in
                guard let log = log else {
                    print(#function + "画像追加失敗")
                    return
                }
                self.log = log
            }
        }
    }
    
    func updatePicture(image: UIImage) {
        if case .part(let id) = state,
           let part = log.partsList.first(where: {$0.id == id}) {
            makeupLogRepository.updateFacePart(logID: log.id!,
                                               part: part,
                                               image: image) { log in
                guard let log = log else {
                    print(#function + "画像追加失敗")
                    return
                }
                self.log = log
                self.state = .part(partID: id)
            }
        }
    }
    
    @objc func didPushNewPhoto() {
        delegate?.viewModelDidPushNewPhoto(self)
    }
}

extension MakeupLogViewModel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 顔全体写真とパーツの合計
        return log.partsList.count + 1
    }
    
    fileprivate func addImageView(_ imageData: Data, _ cell: UICollectionViewCell, _ part: FacePart) {
        let view = AnnotationMoveImageView<Self>(image: UIImage(data: imageData)!)
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
    }
    
    fileprivate func addButton(_ cell: UICollectionViewCell) {
        let button: UIButton = {
            var config = UIButton.Configuration.tinted()
            config.image = UIImage(systemName: "person.2.circle.fill")
            config.buttonSize = .large
            config.background.cornerRadius = 0
            // 背景の設定
            config.baseBackgroundColor = .systemGreen

            let button = UIButton(configuration: config)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("写真を追加", for: .normal)
            button.setTitleColor(.systemBlue, for: .normal)
            return button
        }()

        button.isUserInteractionEnabled = true
        button.frame.size = cell.frame.size
        button.addTarget(self, action: #selector(didPushNewPhoto), for: .touchUpInside)
        cell.contentView.addSubview(button)
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
            if let imageData = makeupLogRepository.imageData(imagePath: log.imagePath) {
                image.image = UIImage(data: imageData)
            }
            image.frame.size = cell.frame.size
            image.contentMode = .scaleAspectFit
            return cell
        }
        let part = log.partsList[indexPath.row - 1]
        if let imageData = makeupLogRepository.imageData(imagePath: part.imagePath) {
            addImageView(imageData, cell, part)
        } else {
            addButton(cell)
        }
        cell.contentView.isUserInteractionEnabled = true
        return cell
    }
}


extension MakeupLogViewModel: CommentListAdapterDelegate {
    func commentListAdapterAnnotationList(_ adapter: CommentListAdapter) -> [FaceAnnotationObject] {
        if case .part(let partID) = state,
           let part = log.partsList.first(where: {$0.id == partID}) {
            var annotations = [FaceAnnotationObject]()
            part.annotations.forEach {
                annotations.append($0)
            }
            return annotations
        }
        return []
    }
    
    func commentListAdapter(_ adapter: CommentListAdapter, didSelectCommentCell index: Int) {
        if case .part(let partID) = state,
           let part = log.partsList.first(where: {$0.id == partID}) {
            delegate?.viewModel(self, didSelect: part.annotations[index].makeAnnotation())
        }
        return
    }
    
    func commentListAdapter(_ adapter: CommentListAdapter, didPushAddButton insertIndex: Int) {
        self.appendAnnotation()
        self.delegate?.viewModelAddAnnotation(self)
    }
    
    func commentListAdapter(_ adapter: CommentListAdapter, didDeleteAt index: Int) {
        deleteAnnotation(index: index)
        self.delegate?.viewModelDeleteAnnotation(self)
    }
}

extension MakeupLogViewModel: AnnotationMoveImageViewDelegate {
    typealias AnnotationType = FaceAnnotationObject
    
    func annotationMoveImageView(_ view: AnnotationMoveImageView<MakeupLogViewModel>, didTouched annotationViewFrame: CGRect, and id: AnnotationType.ID) {
        if case .part(let partID) = state,
           let part = log.partsList.first(where: {$0.id == partID}),
           let faceAnnotationObject = part.annotations.first(where: {$0.id == id}) {
            let imageViewRect = view.imageRect()
            let point = CGPoint(x: annotationViewFrame.minX - imageViewRect.minX,
                                y: annotationViewFrame.minY - imageViewRect.minY)
            let pointRatio = PointRatio.make(parentViewSize: imageViewRect.size,
                                             annotationPoint: point)
            let annotation = FaceAnnotation(id: faceAnnotationObject.id!, text: faceAnnotationObject.text, pointRatioOnImage: pointRatio, title: faceAnnotationObject.title, comment: faceAnnotationObject.comment, selectedColorPalletID: faceAnnotationObject.selectedColorPalletID, selectedColorPalletAnnotationID: faceAnnotationObject.selectedColorPalletAnnotationID)
            touchEnded(annotation: annotation)
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
