//
//  ViewController.swift
//  Demo
//
//  Created by 赵江明 on 2020/9/2.
//  Copyright © 2020 赵江明. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var timer: Timer?
    var refresh: AndroidRefresh?

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .white
        tableView.frame = view.frame
        view.addSubview(tableView)
        tableView.dataSource = self
        let refresh = AndroidRefresh(panView: tableView, target: self, refreshSel: #selector(doRefresh))
        view.addSubview(refresh)
        self.refresh = refresh
    }

    @objc func doRefresh() {
        let _ = AndroidTimer.scheduledTimer(withTimeInterval: 5, target: self, selector: #selector(endRefresh), userInfo: nil, repeats: false)
    }

    @objc func endRefresh() {
        refresh?.endRefresh()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}
