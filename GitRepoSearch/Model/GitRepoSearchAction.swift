//
//  GitRepoSearchAction.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import Foundation

enum GitRepoSearchAction {
    case search(SearchAction)
    case checkRateLimitation
}

enum SearchAction {
    case changeWord(String)
    case reloadResult
    case getNextResult
}
