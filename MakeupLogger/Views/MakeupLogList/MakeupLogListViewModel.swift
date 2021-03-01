//
//  MakeupLogListViewModel.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import UIKit

final class MakeupLogListViewModel: NSObject {
    let repository: MakeupLogRepository
    var list = [MakeupLog]()
    var didFinishReloadList: (() -> Void)? = nil
    var didSelectLog: ((MakeupLog) -> Void)? = nil
    
    init(repository: MakeupLogRepository) {
        self.repository = repository
    }
    
    func fetchLog() {
        repository.getLogList { logList in
            self.list = logList
            self.didFinishReloadList?()
        }
    }
}

extension MakeupLogListViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.imageView?.image = list[indexPath.row].image
        cell.textLabel?.text = list[indexPath.row].title
        return cell
    }
    
}

extension MakeupLogListViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = indexPath.row
        let log = list[id]
        didSelectLog?(log)
    }
}
