//
//  GitRepoSearchViewModel.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import Foundation
import Combine

final class GitRepoSearchViewModel {
    let client: GithubAPIClient
    
    init(client: GithubAPIClient) {
        self.client = client
    }
    
    var state = CurrentValueSubject<GitRepoSearchState, Never>(.initial)
    
    var items: [GitRepoItem] {
        switch state.value {
        case .completed(let items, _, _):
            return items
        default:
            return []
        }
    }
    private var searchWord = ""
    
    func doAction(_ action: GitRepoSearchAction) {
        switch action {
        case .changeSearchWord(let word):
            searchWord = word
            // TODO: 流量調整
            guard !word.isEmpty else {
                state.send(.initial)
                return
            }
                        
            // 実リクエストを投げるのは少し待ってから行う
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                // 検索ワードが変更されているようであればリクエストは投げない
                guard self?.searchWord == word else { return }
                
                self?.state.send(.loading)
                let request = GitRepoSearchRequest(query: word, page: 1)
                self?.client.exec(request: request) { [weak self] result in
                    self?.handle(action: action, result: result)
                }
            }
        default:
            break
        }
    }
    
    private func handle(action: GitRepoSearchAction, result: Result<GitRepoSearchResponse, GithubAPIError>) {
        switch (result, action) {
        case (.success(let response), .changeSearchWord(_)):
            guard response.totalCount != 0 else {
                // 0件パターン
                state.send(.empty)
                return
            }
            
            // トータル件数をリクエストのページサイズで割った量が全ページであり、そこから次があるかどうかを設定する
            let currentPage = 1
            let hasNext = response.totalCount / GitRepoSearchRequest.pageSize > currentPage - 1
            state.send(.completed(items: response.items, currentPage: currentPage, hasNext: hasNext))
        default:
            break
        }
    }
}
