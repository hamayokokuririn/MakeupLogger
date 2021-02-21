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
    func viewModel(_ model: MakeupLogViewModel, didChange state: MakeupLogViewModel.ViewState)
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
            delegate?.viewModel(self, didChange: state)
        }
    }
    
    weak var delegate: MakeupLogViewModelDelegate? = nil
    
    var log: MakeupLog
    var tableViewAdapter: CommentListAdapter?
    
    init(log: MakeupLog) {
        self.log = log
        super.init()
    }
    
    func updateTableViewAdapter(part: FacePart) {
        let adapter = CommentListAdapter(annotationList: part.annotations)
        adapter.addAction = { index in
            let idAndText = index.description
            let annotation = FaceAnnotation(id: idAndText,
                                            text: idAndText,
                                            selectedColorPalletAnnotationID: "1")
            self.appendAnnotation(annotation)
            self.delegate?.viewModel(self, add: annotation)
        }
        self.tableViewAdapter = adapter
    }
    
    private func appendAnnotation(_ annotation: FaceAnnotation) {
        if case .part(let part) = self.state {
            if let id = log.partsList.firstIndex(where: {
                $0.type == part.type
            }) {
                self.log.partsList[id].annotations.append(annotation)
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
            self.delegate?.viewModel(self, didChange: .face)
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
                self.updateTableViewAdapter(part: part)
                self.delegate?.viewModel(self, didChange: .part(part))
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
        if indexPath.row == 0 {
            let image = UIImageView()
            cell.addSubview(image)
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
        cell.contentView.addSubview(view)
        cell.contentView.isUserInteractionEnabled = true
        return cell
    }
    
}
