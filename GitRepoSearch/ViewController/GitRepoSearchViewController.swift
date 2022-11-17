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
    @IBOutlet weak var rateLimitView: UIView!
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
        resultTableView.register(PagingIndicatorTableViewCell.self)
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
                guard let sSelf = self else { return }
                switch $0 {
                case .initial:
                    sSelf.showStackContent(targetView: sSelf.initialView)
                case .loading(true):
                    sSelf.showStackContent(targetView: sSelf.loadingView)
                case .loading(false):
                    // インジケータを表示しない読み込み中に関しては何もしない
                    break
                case .completed(let isMoveToTop):
                    sSelf.showStackContent(targetView: sSelf.resultTableView)

                    if isMoveToTop {
                        // スクロール位置が残ってしまっている場合があるので、初期化する必要がある場合はゼロ位置へ
                        sSelf.resultTableView.setContentOffset(.zero, animated: false)
                    }
                    
                    sSelf.refreshControl.endRefreshing()
                    sSelf.resultTableView.reloadData()
                    sSelf.resultTableView.flashScrollIndicators()
                case .empty:
                    sSelf.showStackContent(targetView: sSelf.emptyView)
                case .error:
                    sSelf.showStackContent(targetView: sSelf.errorView)
                case .rateLimit:
                    sSelf.showStackContent(targetView: sSelf.rateLimitView)
                    // 入力も初期化しておく
                    sSelf.searchBar.text = ""
                }
        })
        .store(in: &subscriptions)
        
    }
    
    @objc func refresh() {
        // Pull To Refresh
        viewModel.doAction(.reloadSearchResult)
    }
    
    @IBAction func tappedRateLimitConfirmButton(_ sender: Any) {
        viewModel.doAction(.checkRateLimitation)
    }

    private var stackViews: [UIView] {
        [initialView, loadingView, errorView, emptyView, rateLimitView, resultTableView]
    }
    
    private func showStackContent(targetView: UIView) {
        targetView.isHidden = false
        // 上記以外は非表示にする
        stackViews.filter { $0 != targetView }.forEach { $0.isHidden = true }
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UIScrollViewDelegate
extension GitRepoSearchViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // ページングが有効な場合のみ、スクロール量をチェック
        guard viewModel.hasNext else { return }
        
        let scrollPositon = scrollView.contentOffset.y
        let margin: CGFloat = 44
        
        // スクロールが最下部の要素になったら次を取得
        if scrollPositon > scrollView.contentSize.height - scrollView.bounds.height - margin {
            viewModel.doAction(.getNextSearchResult)
        }
    }
}

extension GitRepoSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

private enum GitRepoSearchSection: Int {
    case gitRepoItemCell = 0
    case pagingIndicatorCell = 1
}

extension GitRepoSearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // 次の要素がある場合は読み込み用のセクションを追加するため2として返す
        viewModel.hasNext ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch GitRepoSearchSection(rawValue: section) {
        case .gitRepoItemCell:
            return viewModel.items.count
        case .pagingIndicatorCell:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch GitRepoSearchSection(rawValue: indexPath.section) {
        case .gitRepoItemCell:
            let cell = tableView.dequeueReusableCell(cellClass: GitRepoSearchResultTableViewCell.self, for: indexPath)
            cell.apply(item: viewModel.items[indexPath.row])
            return cell
        case .pagingIndicatorCell:
            return tableView.dequeueReusableCell(cellClass: PagingIndicatorTableViewCell.self, for: indexPath)
        default:
            return UITableViewCell()
        }
    }
}
