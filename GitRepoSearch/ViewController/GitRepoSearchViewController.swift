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
    @IBOutlet weak var initialView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var resultTableView: UITableView!
    
    var viewModel: GitRepoSearchViewModel!
    
    var subscriptions = Set<AnyCancellable>()
    
    var refreshControl = UIRefreshControl()
    
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
        resultTableView.register(GitRepoSearchResultTableViewCell.self)
        // セルの繰り返し表示を消す
        resultTableView.tableFooterView = UIView()
        
        resultTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        bind()
    }
    
    private func bind() {
        viewModel
            .state
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                switch $0 {
                case .initial:
                    self?.initialView.isHidden = false
                    self?.loadingView.isHidden = true
                    self?.errorView.isHidden = true
                    self?.emptyView.isHidden = true
                    self?.resultTableView.isHidden = true
                case .loading:
                    self?.initialView.isHidden = true
                    self?.loadingView.isHidden = false
                    self?.errorView.isHidden = true
                    self?.emptyView.isHidden = true
                    self?.resultTableView.isHidden = true
                case .completed:
                    self?.initialView.isHidden = true
                    self?.loadingView.isHidden = true
                    self?.errorView.isHidden = true
                    self?.emptyView.isHidden = true
                    self?.resultTableView.isHidden = false
                    self?.refreshControl.endRefreshing()
                    self?.resultTableView.reloadData()
                case .empty:
                    self?.initialView.isHidden = true
                    self?.loadingView.isHidden = true
                    self?.errorView.isHidden = true
                    self?.emptyView.isHidden = false
                    self?.resultTableView.isHidden = true
                case .error:
                    self?.initialView.isHidden = true
                    self?.loadingView.isHidden = true
                    self?.errorView.isHidden = false
                    self?.emptyView.isHidden = true
                    self?.resultTableView.isHidden = true
                }
        })
        .store(in: &subscriptions)
        
    }
    
    @objc func refresh() {
        // Pull To Refresh
        viewModel.doAction(.reloadSearchResult)
    }
}

extension GitRepoSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.doAction(.changeSearchWord(searchText))
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if case .loading = viewModel.state.value {
            // リクエスト中の場合はテキスト変更をさせない
            return false
        } else {
            return true
        }
    }
}

extension GitRepoSearchViewController: UITableViewDelegate {
}

extension GitRepoSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(cellClass: GitRepoSearchResultTableViewCell.self, for: indexPath)
        cell.apply(item: viewModel.items[indexPath.row])
        return cell
    }
}
