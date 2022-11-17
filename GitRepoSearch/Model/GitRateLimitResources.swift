//
//  GitRateLimitResources.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import Foundation

struct GitRateLimitResources: Decodable {
    // NOTE: 今回は検索のみの実装なのでこれだけレスポンスをチェック
    let search: GitRateLimit
}
