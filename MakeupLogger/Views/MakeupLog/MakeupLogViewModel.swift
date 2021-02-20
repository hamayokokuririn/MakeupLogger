//
//  MakeupLogViewModel.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import UIKit

final class MakeupLogViewModel {
    let log: MakeupLog
    var didChangeSegment: ((FacePart) -> Void)?
    
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
        }
        list.append((action: action, index: 0))
        for (index, part) in log.partsList.enumerated() {
            let action = UIAction(title: part.type,
                                  image: nil,
                                  identifier: nil,
                                  discoverabilityTitle: nil,
                                  attributes: .destructive,
                                  state: .off) { _ in
                print(part.type)
                self.didChangeSegment?(part)
            }
            list.append((action: action, index: index + 1))
        }
        return list
    }
}
