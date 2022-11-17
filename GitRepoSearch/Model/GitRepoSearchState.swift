//
//  GitRepoSearchState.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import Foundation

enum GitRepoSearchState {
    case initial
    case completed
    case empty
    case rateLimit
    case error
    case loading(isShowActivityIndicator: Bool)
}
