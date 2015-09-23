//
//  ViewControllerSwift.swift
//  RunLoopWorkDistribution
//
//  Created by Di Wu on 9/23/15.
//  Copyright © 2015 Di Wu. All rights reserved.
//

import UIKit

class ViewControllerSwift: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var exampleTableView: UITableView?
    private static let IDENTIFIER = "IDENTIFIER"
    private static let CELL_HEIGHT: CGFloat = 135.0
    override func loadView() {
        view = UIView()
        exampleTableView = UITableView()
        exampleTableView?.delegate = self
        exampleTableView?.dataSource = self
        view.addSubview(exampleTableView!)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        exampleTableView?.frame = view.bounds
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        exampleTableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: ViewControllerSwift.IDENTIFIER)
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ViewControllerSwift.CELL_HEIGHT
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(ViewControllerSwift.IDENTIFIER)!
        cell.selectionStyle = .None
        cell.currentIndexPath = indexPath
        ViewController.task_5(cell, indexPath: indexPath)
        ViewController.task_1(cell, indexPath: indexPath)
        DWURunLoopWorkDistribution.sharedRunLoopWorkDistribution().addTask({ () -> Bool in
            if cell.currentIndexPath .isEqual(indexPath) == false {
                return false
            } else {
                ViewController.task_2(cell, indexPath: indexPath)
                return true
            }
        }, withKey: indexPath)
        DWURunLoopWorkDistribution.sharedRunLoopWorkDistribution().addTask({ () -> Bool in
            if cell.currentIndexPath .isEqual(indexPath) == false {
                return false
            } else {
                ViewController.task_3(cell, indexPath: indexPath)
                return true
            }
            }, withKey: indexPath)
        DWURunLoopWorkDistribution.sharedRunLoopWorkDistribution().addTask({ () -> Bool in
            if cell.currentIndexPath .isEqual(indexPath) == false {
                return false
            } else {
                ViewController.task_4(cell, indexPath: indexPath)
                return true
            }
            }, withKey: indexPath)
        return cell;
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 399
    }

}