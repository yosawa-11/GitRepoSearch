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
    
    func doAction(_ action: GitRepoSearchAction) {
        switch action {
        case .changeSearchWord(let word):
            let request = GitRepoSearchRequest(query: word, page: 1)
            client.exec(request: request) { [weak self] result in
                self?.handle(action: action, result: result)
            }
        default:
            break
        }
    }
    
    private func handle(action: GitRepoSearchAction, result: Result<GitRepoSearchResponse, GithubAPIError>) {
        switch (result, action) {
        case (.success(let response), .changeSearchWord(_)):
            // トータル件数をリクエストのページサイズで割った量が全ページであり、そこから次があるかどうかを設定する
            let currentPage = 1
            let hasNext = response.totalCount / GitRepoSearchRequest.pageSize > currentPage - 1
            state.send(.completed(items: response.items, currentPage: currentPage, hasNext: hasNext))
        default:
            break
        }
        
    }
}
