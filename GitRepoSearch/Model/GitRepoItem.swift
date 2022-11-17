//
//  GitRepoItem.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import Foundation

// NOTE: 最低限の使用するものだけを定義
struct GitRepoItem: Decodable {
    let name: String
    let description: String?
}
