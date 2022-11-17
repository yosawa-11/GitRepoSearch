//
//  GitRateLimitRequest.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import Foundation

struct GitRateLimitRequest: GithubAPIRequest {
    typealias ResponseType = GitRateLimitResponse

    var token: String = ""
    
    var path: String {
        "rate_limit"
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var encoding: Encoding {
        .URLEncoding
    }
    
    var parameters: [String: Any] {
        [:]
    }
}
