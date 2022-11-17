//
//  GithubAPIRequest.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import Foundation

protocol GithubAPIRequest: APIRequest {
    associatedtype ResponseType: Decodable
    var token: String { get set }
}

extension GithubAPIRequest {
    var host: String {
        "api.github.com"
    }
    
    var schema: String {
        "https"
    }
    
    var httpHeader: [String: String] {
        [
            "Accept": "application/vnd.github+json",
            "Authorization": "Bearer \(token)"
        ]
    }
}
