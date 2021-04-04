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
    
    init(makeupLogRepository: MakeupLogRepository, colorPalletRepository: ColorPalletRepository) {
        self.viewModel = MakeupLogListViewModel(makeupLogRepository: makeupLogRepository, colorPalletRepository: colorPalletRepository)
        super.init(nibName: nil, bundle: nil)
        
        viewModel.didFinishReloadList = {
            self.tableView.reloadData()
        }
        
        viewModel.didSelectLog = { log in
            let vc = MakeupLogViewController(log: log)
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
        
        let item = UIBarButtonItem(barButtonSystemItem: .add,
                                   target: self,
                                   action: #selector(didPushAddButton))
        self.navigationItem.rightBarButtonItem = item
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.frame
    }
    
    @objc private func didPushAddButton() {
        viewModel.showAlert(presenter: self)
    }
    
    private func addNewMakeupLog() {
        // 新規のログを追加する画面を表示
        let vc = AddNewMakeupLogViewController(repository: viewModel.makeupLogRepository)
        let navigation = UINavigationController(rootViewController: vc)
        navigation.presentationController?.delegate = self
        present(navigation, animated: true, completion: nil)
    }
    
    private func addNewColorPallet() {
        // 新規のカラーを追加する画面を表示
        let vc = AddNewColorPalletViewController(repository: viewModel.colorPalletRepository)
        let navigation = UINavigationController(rootViewController: vc)
        navigation.presentationController?.delegate = self
        present(navigation, animated: true, completion: nil)
    }
}

extension MakeupLogListViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        dismiss(animated: true, completion: nil)
        viewModel.fetchLog()
    }
}
