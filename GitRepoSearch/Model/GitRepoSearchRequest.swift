//
//  GitRepoSearchRequest.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import Foundation

struct GitRepoSearchRequest: GithubAPIRequest {
    typealias ResponseType = GitRepoSearchResponse

    // TODO: ベタ書きやめてあとで切り出す
    var token: String = "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"
    
    var path: String {
        "search/repositories"
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var encoding: Encoding {
        .URLEncoding
    }
    
    var parameters: [String: Any] {
        [
            "q": query,
            "page": page
        ]
    }
    
    let query: String
    let page: Int
}
