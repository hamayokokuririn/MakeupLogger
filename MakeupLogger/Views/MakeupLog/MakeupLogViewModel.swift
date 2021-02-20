//
//  MakeupLogViewModel.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import UIKit

final class MakeupLogViewModel: NSObject {
    let log: MakeupLog
    var didChangeSegment: ((IndexPath) -> Void)?
    
    init(log: MakeupLog) {
        self.log = log
    }
    
    func segmentActionList() -> [(action: UIAction, index: Int)] {
        var list = [(action: UIAction, index: Int)]()
        let action = UIAction(title: "face",
                              image: nil, identifier: nil, discoverabilityTitle: nil,
                              attributes: .destructive,
                              state: .on) { _ in
            print("face")
            self.didChangeSegment?(IndexPath(row: 0,
                                             section: 0))
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
                self.didChangeSegment?(IndexPath(row: indexPlus1,
                                                 section: 0))
            }
            list.append((action: action, index: indexPlus1))
        }
        return list
    }
}

extension MakeupLogViewModel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
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
        if indexPath.row == 1 {
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
        return cell
    }
    
}
