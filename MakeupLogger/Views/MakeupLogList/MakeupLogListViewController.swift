//
//  MakeupLogListViewController.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import UIKit
import SafariServices

final class MakeupLogListViewController: UIViewController {
    enum Mode {
        case top
        case selectColorPallet
    }
    
    let mode: Mode
    let viewModel: MakeupLogListViewModel
    
    let tableView = UITableView()
    
    init(mode: Mode = .top, makeupLogRepository: MakeupLogRepository, colorPalletRepository: ColorPalletRepository) {
        self.viewModel = MakeupLogListViewModel(mode: mode, makeupLogRepository: makeupLogRepository, colorPalletRepository: colorPalletRepository)
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
        
        viewModel.didFinishReloadList = {
            self.tableView.reloadData()
        }
        
        viewModel.didSelectLog = { log in
            let vc = MakeupLogViewController(log: log,
                                             makeupLogRepository: makeupLogRepository,
                                             colorPalletRepository: colorPalletRepository)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        viewModel.didSelectColorPallet = {
            let vc = ColorPalletViewController(colorPallet: $0, repository: colorPalletRepository)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        viewModel.didSelectAddMakeupLog = {
            self.addNewMakeupLog()
        }
        
        viewModel.didSelectAddColorPallet = {
            self.addNewColorPallet()
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
        
        let right = UIBarButtonItem(barButtonSystemItem: .add,
                                   target: self,
                                   action: #selector(didPushAddButton))
        self.navigationItem.rightBarButtonItem = right
        
        let left = UIBarButtonItem(image: UIImage(systemName: "info.circle"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(didPushInfoButton))
        self.navigationItem.leftBarButtonItem = left
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.frame
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.fetchLog()
    }
    
    @objc private func didPushAddButton() {
        viewModel.showAlert(presenter: self)
    }
    
    @objc private func didPushInfoButton() {
        let url = URL(string: "https://field-level-e6c.notion.site/5d8082859fab444b8af2226ecbb3fedc?v=deb09b5cf45a41d8afcc19a9eced153c")!
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
    private func addNewMakeupLog() {
        // 新規のログを追加する画面を表示
        let vc = AddNewMakeupLogViewController(repository: viewModel.makeupLogRepository)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func addNewColorPallet() {
        // 新規のカラーを追加する画面を表示
        let vc = AddNewColorPalletViewController(repository: viewModel.colorPalletRepository)
        navigationController?.pushViewController(vc, animated: true)
    }
}
