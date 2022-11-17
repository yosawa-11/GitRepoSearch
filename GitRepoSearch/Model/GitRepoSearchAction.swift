//
//  GitRepoSearchAction.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import Foundation

enum GitRepoSearchAction {
    case changeSearchWord(String)
    case reloadSearchResult
    case getNextSearchResult
    case checkRateLimitation
}
