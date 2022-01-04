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
                return "メイクアップログ"
            case .colorPallet:
                return "カラーパレット"
            }
        }
    }
    
    let mode: MakeupLogListViewController.Mode
    let makeupLogRepository: MakeupLogRepository
    let colorPalletRepository: ColorPalletRepository
    var makeupLogList = [MakeupLog]()
    var colorPalletList = [ColorPallet]()
    var didFinishReloadList: (() -> Void)? = nil
    var didSelectLog: ((MakeupLog) -> Void)? = nil
    var didSelectColorPallet: ((ColorPallet) -> Void)? = nil
    var didSelectAddMakeupLog: (() -> Void)? = nil
    var didSelectAddColorPallet: (() -> Void)? = nil
    
    init(mode: MakeupLogListViewController.Mode, makeupLogRepository: MakeupLogRepository, colorPalletRepository: ColorPalletRepository) {
        self.mode = mode
        self.makeupLogRepository = makeupLogRepository
        self.colorPalletRepository = colorPalletRepository
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fetchLog),
                                               name: .didLogUpdate,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fetchLog),
                                               name: .didColorPalletUpdate,
                                               object: nil)
    }
    
    @objc func fetchLog() {
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
        switch mode {
        case .top:
            guard let section = Section(rawValue: section) else {
                return 0
            }
            switch section {
            case .makeupLog:
                return makeupLogList.count
            case .colorPallet:
                return colorPalletList.count
            }
        case .selectColorPallet:
            return colorPalletList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch mode {
        case .top:
            guard let section = Section(rawValue: indexPath.section) else {
                return UITableViewCell()
            }
            return makeCell(section: section, indexPath: indexPath)
        case .selectColorPallet:
            return makeCell(section: .colorPallet, indexPath: indexPath)
        }
        
    }
    
    private func makeCell(section: Section, indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        switch section {
        case .makeupLog:
            if let imageData = makeupLogRepository.imageData(imagePath: makeupLogList[indexPath.row].imagePath) {
                cell.imageView?.image = UIImage(data: imageData)
            }
            cell.textLabel?.text = makeupLogList[indexPath.row].title
        case .colorPallet:
            if let data = ColorPalletRealmRepository.imageData(imagePath: colorPalletList[indexPath.row].imagePath) {
                cell.imageView?.image = UIImage(data: data)
            }
            cell.textLabel?.text = colorPalletList[indexPath.row].title
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch mode {
        case .top:
            return Section.allCases.count
        case .selectColorPallet:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch mode {
        case .top:
            guard let section = Section(rawValue: section) else {
                return ""
            }
            return section.title
        case .selectColorPallet:
            return Section.colorPallet.title
        }
    }
}

extension MakeupLogListViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch mode {
        case .top:
            guard let section = Section(rawValue: indexPath.section) else {
                return
            }
            didSelectRowAt(indexPath: indexPath, in: section)
        case .selectColorPallet:
            didSelectRowAt(indexPath: indexPath, in: .colorPallet)
        }
    }
    
    private func didSelectRowAt(indexPath: IndexPath, in section: Section) {
        switch section {
        case .makeupLog:
            let id = indexPath.row
            let log = makeupLogList[id]
            didSelectLog?(log)
        case .colorPallet:
            // カラーパレット編集を行う
            let row = indexPath.row
            let colorPallet = colorPalletList[row]
            didSelectColorPallet?(colorPallet)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch mode {
        case .top:
            return true
        case .selectColorPallet:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .none:
            break
        case .delete:
            guard let section = Section(rawValue: indexPath.section) else {
                return
            }
            switch section {
            case .makeupLog:
                if makeupLogList.indices.contains(indexPath.row) {
                    let target = makeupLogList[indexPath.row]
                    makeupLogList.remove(at: indexPath.row)
                    makeupLogRepository.delete(logID: target.id!)
                }
                
            case .colorPallet:
                if colorPalletList.indices.contains(indexPath.row) {
                    let target = colorPalletList[indexPath.row]
                    colorPalletRepository.delete(id: target.id!)
                    colorPalletList.remove(at: indexPath.row)
                }
            }
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        case .insert:
            break
        @unknown default:
            break
        }
    }
}
