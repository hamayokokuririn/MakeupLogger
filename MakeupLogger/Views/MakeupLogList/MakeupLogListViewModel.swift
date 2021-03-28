//
//  MakeupLogListViewModel.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import UIKit

final class MakeupLogListViewModel: NSObject {
    enum Section: Int, CaseIterable {
        case makeupLog
        case colorPallet
        
        var title: String {
            switch self {
            case .makeupLog:
                return "メイク"
            case .colorPallet:
                return "カラー"
            }
        }
    }
    
    let makeupLogRepository: MakeupLogRepository
    let colorPalletRepository: ColorPalletRepository
    var list = [MakeupLog]()
    var didFinishReloadList: (() -> Void)? = nil
    var didSelectLog: ((MakeupLog) -> Void)? = nil
    
    init(makeupLogRepository: MakeupLogRepository, colorPalletRepository: ColorPalletRepository) {
        self.makeupLogRepository = makeupLogRepository
        self.colorPalletRepository = colorPalletRepository
    }
    
    func fetchLog() {
        makeupLogRepository.getLogList { logList in
            self.list = logList
            self.didFinishReloadList?()
        }
    }
}

extension MakeupLogListViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            return 0
        }
        switch section {
        case .makeupLog:
            return list.count
        case .colorPallet:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.imageView?.image = list[indexPath.row].image
        cell.textLabel?.text = list[indexPath.row].title
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else {
            return ""
        }
        return section.title
    }
}

extension MakeupLogListViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let id = indexPath.row
        let log = list[id]
        didSelectLog?(log)
    }
}
