//
//  GitRepoSearchViewController.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import UIKit

final class GitRepoSearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初期セットアップ
        searchBar.delegate = self
        resultTableView.delegate = self
        resultTableView.dataSource = self
        // セルの繰り返し表示を消す
        resultTableView.tableFooterView = UIView()
    }
}

extension GitRepoSearchViewController: UISearchBarDelegate {
}

extension GitRepoSearchViewController: UITableViewDelegate {
}

extension GitRepoSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}
