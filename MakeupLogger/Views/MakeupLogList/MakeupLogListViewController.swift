//
//  MakeupLogListViewController.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import UIKit

final class MakeupLogListViewController: UIViewController {
    let viewModel: MakeupLogListViewModel
    
    let tableView = UITableView()
    
    init(repository: MakeupLogRepository) {
        self.viewModel = MakeupLogListViewModel(repository: repository)
        super.init(nibName: nil, bundle: nil)
        
        viewModel.didFinishReloadList = {
            self.tableView.reloadData()
        }
        
        viewModel.didSelectLog = { log in
            let vc = MakeupLogViewController(log: log)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchLog()
        
        view.addSubview(tableView)
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.frame
    }
}
