//
//  ViewControllerSwift.swift
//  RunLoopWorkDistribution
//
//  Created by Di Wu on 9/23/15.
//  Copyright © 2015 Di Wu. All rights reserved.
//

import UIKit

class ViewControllerSwift: UIViewController, UITableViewDelegate, UITableViewDataSource {
    fileprivate var exampleTableView: UITableView?
    fileprivate static let IDENTIFIER = "IDENTIFIER"
    fileprivate static let CELL_HEIGHT: CGFloat = 135.0
    override func loadView() {
        view = UIView()
        exampleTableView = UITableView()
        exampleTableView?.delegate = self
        exampleTableView?.dataSource = self
        view.addSubview(exampleTableView!)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        exampleTableView?.frame = view.bounds
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        exampleTableView?.register(UITableViewCell.self, forCellReuseIdentifier: ViewControllerSwift.IDENTIFIER)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ViewControllerSwift.CELL_HEIGHT
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: ViewControllerSwift.IDENTIFIER)!
        cell.selectionStyle = .none
        cell.currentIndexPath = indexPath
        ViewController.task_5(cell, indexPath: indexPath)
        ViewController.task_1(cell, indexPath: indexPath)
        DWURunLoopWorkDistribution.shared().addTask({ () -> Bool in
            if cell.currentIndexPath != indexPath {
                return false
            } else {
                ViewController.task_2(cell, indexPath: indexPath)
                return true
            }
        }, withKey: indexPath)
        DWURunLoopWorkDistribution.shared().addTask({ () -> Bool in
            if cell.currentIndexPath != indexPath {
                return false
            } else {
                ViewController.task_3(cell, indexPath: indexPath)
                return true
            }
            }, withKey: indexPath)
        DWURunLoopWorkDistribution.shared().addTask({ () -> Bool in
            if cell.currentIndexPath != indexPath {
                return false
            } else {
                ViewController.task_4(cell, indexPath: indexPath)
                return true
            }
            }, withKey: indexPath)
        return cell;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 399
    }

}
