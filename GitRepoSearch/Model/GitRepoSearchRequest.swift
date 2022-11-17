//
//  GitRepoSearchRequest.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import Foundation

struct GitRepoSearchRequest: GithubAPIRequest {
    typealias ResponseType = GitRepoSearchResponse

    var token: String = ""
    
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
            "page": page,
            "per_page": Self.pageSize
        ]
    }
    
    let query: String
    let page: Int
    static let pageSize = 30
}
