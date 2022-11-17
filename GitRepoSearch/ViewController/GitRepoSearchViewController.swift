//
//  GitRepoSearchViewController.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import UIKit
import Combine

final class GitRepoSearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultTableView: UITableView!
    
    var viewModel: GitRepoSearchViewModel!
    
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NOTE: DIライブラリで入れ込みたい
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let client = GithubAPIClient(urlSession: URLSession(configuration: .default), jsonDecoder: jsonDecoder)
        viewModel = GitRepoSearchViewModel(client: client)
        
        // 初期セットアップ
        searchBar.delegate = self
        resultTableView.delegate = self
        resultTableView.dataSource = self
        // セルの繰り返し表示を消す
        resultTableView.tableFooterView = UIView()
        
        bind()
        
        // TODO: おためし
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.viewModel.doAction(.changeSearchWord("test"))
        })
    }
    
    private func bind() {
        viewModel
            .state
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                switch $0 {
                case .completed:
                    self?.resultTableView.reloadData()
                default:
                    break
                }
        })
        .store(in: &subscriptions)
    }
}

extension GitRepoSearchViewController: UISearchBarDelegate {
}

extension GitRepoSearchViewController: UITableViewDelegate {
}

extension GitRepoSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}
