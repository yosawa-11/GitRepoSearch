//
//  GitRepoSearchState.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import Foundation

enum GitRepoSearchState {
    case initial
    case completed(items: [GitRepoItem], currentPage: Int, hasNext: Bool)
    case error
    case loading
}
