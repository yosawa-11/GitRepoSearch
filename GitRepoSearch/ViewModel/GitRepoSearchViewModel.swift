//
//  GitRepoSearchViewModel.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import Foundation
import Combine

final class GitRepoSearchViewModel {
    private let client: GithubAPIClient
    
    init(client: GithubAPIClient) {
        self.client = client
    }
    
    private(set) var state = CurrentValueSubject<GitRepoSearchState, Never>(.initial)
    
    private(set) var items: [GitRepoItem] = []
    private var currentPage = 1
    private(set) var hasNext = false
    private var searchWord = ""
    
    func doAction(_ action: GitRepoSearchAction) {
        switch action {
        case .changeSearchWord(let word):
            searchWord = word
            
            guard !word.isEmpty else {
                state.send(.initial)
                return
            }
            
            // 負荷軽減のため実リクエストを投げるのは少し待ってから行う
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                // 検索ワードが変更されているようであればリクエストは投げない（後続の処理が実行される）
                guard self?.searchWord == word else { return }
                
                self?.state.send(.loading(isShowActivityIndicator: true)) // 検索ワードを変更した場合のみインジケータを表示
                self?.sendSearchRequest(action: action, searchWord: word)
            }
        case .reloadSearchResult:
            state.send(.loading(isShowActivityIndicator: false))
            sendSearchRequest(action: action, searchWord: searchWord)
        case .getNextSearchResult:
            // 読み込み中でない場合のみ実施
            if case .loading = state.value { } else {
                state.send(.loading(isShowActivityIndicator: false))
                sendSearchRequest(action: action, searchWord: searchWord, page: currentPage + 1)
            }
        case .checkRateLimitation:
            // レート制限のチェック
            state.send(.loading(isShowActivityIndicator: true))
            let request = GitRateLimitRequest()
            client.exec(request: request) { [weak self] result in
                switch result {
                case .success(let response) where response.resources.search.remaining > 0:
                    self?.state.send(.initial)
                default:
                    self?.state.send(.rateLimit)
                }
            }
        }
    }
    
    private func sendSearchRequest(action: GitRepoSearchAction, searchWord: String, page: Int = 1) {
        let request = GitRepoSearchRequest(query: searchWord, page: page)
        client.exec(request: request) { [weak self] result in
            self?.handle(action: action, page: page, result: result)
        }
    }
    
    private func handle(action: GitRepoSearchAction, page: Int, result: Result<GitRepoSearchResponse, GithubAPIError>) {
        switch (result, action) {
        case (.success(let response), .changeSearchWord(_)),
            (.success(let response), .reloadSearchResult):
            guard response.totalCount != 0 else {
                // 0件パターン
                state.send(.empty)
                return
            }
            
            // トータル件数をリクエストのページサイズで割った量が全ページであり、そこから次があるかどうかを設定する
            hasNext = response.totalCount / GitRepoSearchRequest.pageSize > page - 1
            items = response.items
            currentPage = page
            state.send(.completed(isMoveToTop: true))
        case (.success(let response), .getNextSearchResult):
            hasNext = response.totalCount / GitRepoSearchRequest.pageSize > page - 1
            items = items + response.items
            currentPage = page
            state.send(.completed(isMoveToTop: false))
        case (.failure(.rateLimitError), _):
            state.send(.rateLimit)
        case (.failure(let error), _):
            print(error)
            state.send(.error)
        case (_, .checkRateLimitation):
            // 実行されないので何もしない
            break
        }
    }
}
