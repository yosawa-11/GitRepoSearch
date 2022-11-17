//
//  GitRateLimitResponse.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import Foundation

struct GitRateLimitResponse: Decodable {
    let resources: GitRateLimitResources
}
