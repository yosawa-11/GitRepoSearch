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
    
    var client: GithubAPIClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初期セットアップ
        searchBar.delegate = self
        resultTableView.delegate = self
        resultTableView.dataSource = self
        // セルの繰り返し表示を消す
        resultTableView.tableFooterView = UIView()
        
        // TODO: お試しリクエスト
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        client = GithubAPIClient(urlSession: URLSession(configuration: .default), jsonDecoder: jsonDecoder)
        client.exec(request: GitRepoSearchRequest(query: "ほげほげ", page: 1), completion: { _ in })
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
