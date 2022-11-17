//
//  GitRepoSearchResponse.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import Foundation

struct GitRepoSearchResponse: Decodable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [GitRepoItem]
}
