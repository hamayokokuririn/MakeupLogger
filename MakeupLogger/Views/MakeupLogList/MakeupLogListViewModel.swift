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
    var makeupLogList = [MakeupLog]()
    var colorPalletList = [ColorPallet]()
    var didFinishReloadList: (() -> Void)? = nil
    var didSelectLog: ((MakeupLog) -> Void)? = nil
    var didSelectAddMakeupLog: (() -> Void)? = nil
    var didSelectAddColorPallet: (() -> Void)? = nil
    
    init(makeupLogRepository: MakeupLogRepository, colorPalletRepository: ColorPalletRepository) {
        self.makeupLogRepository = makeupLogRepository
        self.colorPalletRepository = colorPalletRepository
    }
    
    func fetchLog() {
        makeupLogRepository.getLogList { logList in
            self.makeupLogList = logList
            colorPalletRepository.getColorPalletList { list in
                self.colorPalletList = list
                self.didFinishReloadList?()
            }
        }
    }
    
    func showAlert(presenter: UIViewController) {
        let alert = UIAlertController(title: "何を追加しますか？",
                                      message: nil,
                                      preferredStyle: .alert)
        let cameraAction = UIAlertAction(title: "メイクを追加",
                                        style: .default) { _ in
            self.didSelectAddMakeupLog?()
        }
        alert.addAction(cameraAction)
        
        let photoLibraryAction = UIAlertAction(title: "カラーを追加",
                                               style: .default) { _ in
            self.didSelectAddColorPallet?()
        }
        alert.addAction(photoLibraryAction)
        let cancelAction = UIAlertAction(title: "キャンセル",
                                               style: .cancel) { _ in
            presenter.dismiss(animated: false, completion: nil)
        }
        alert.addAction(cancelAction)
        presenter.present(alert, animated: true, completion: nil)
    }
}

extension MakeupLogListViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            return 0
        }
        switch section {
        case .makeupLog:
            return makeupLogList.count
        case .colorPallet:
            return colorPalletList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        guard let section = Section(rawValue: indexPath.section) else {
            return cell
        }
        switch section {
        case .makeupLog:
            cell.imageView?.image = makeupLogList[indexPath.row].image
            cell.textLabel?.text = makeupLogList[indexPath.row].title
        case .colorPallet:
            cell.imageView?.image = colorPalletList[indexPath.row].image
            cell.textLabel?.text = colorPalletList[indexPath.row].title
        }
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
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        switch section {
        case .makeupLog:
            let id = indexPath.row
            let log = makeupLogList[id]
            didSelectLog?(log)
        case .colorPallet:
            // カラーパレット編集を行う
            return
        }
        
    }
}
