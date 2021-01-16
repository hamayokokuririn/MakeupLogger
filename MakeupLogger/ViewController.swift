//
//  ViewController.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/01/09.
//

import UIKit

class ViewController: UIViewController {

    let image = UIImage(named: "sample_face")
    lazy var faceView = UIImageView(image: image)
    
    let tableView = UITableView()
    lazy var adapter: CommentListAdapter? = {
        let adapter = CommentListAdapter(annotaionList: ["comment1"])
        adapter.addAction = {
            self.addAnnotaion()
        }
        return adapter
    }()
    
    private func addAnnotaion() {
        let annotaion = UIView()
        annotaion.backgroundColor = .red
        annotaion.frame.size = CGSize(width: 20, height: 20)
        faceView.addSubview(annotaion)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray3
        view.addSubview(faceView)
        view.addSubview(tableView)
        
        faceView.backgroundColor = .black
        faceView.contentMode = .scaleAspectFit
        
        tableView.dataSource = adapter
        tableView.delegate = adapter
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let mainFrame = view.frame
        let imageWidth = CGFloat(300)
        let imageHeight = CGFloat(500)
        let margin = (mainFrame.width - imageWidth)/2
        let safeAreaInsets = view.safeAreaInsets
        faceView.frame = CGRect(x: margin,
                                y: safeAreaInsets.top,
                                width: imageWidth,
                                height: imageHeight)
        
        let tableViewTop = faceView.frame.maxY + CGFloat(24)
        let tableViewHeight = mainFrame.height - tableViewTop - view.safeAreaInsets.bottom
        tableView.frame = CGRect(x: margin,
                                 y: tableViewTop,
                                 width: imageWidth,
                                 height: tableViewHeight)
    }

    
}
