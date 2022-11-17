//
//  GitRateLimit.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import Foundation

struct GitRateLimit: Decodable {
    let limit: Int
    let used: Int
    let remaining: Int
    let reset: TimeInterval
}

extension GitRateLimit {
    var resetDate: Date {
        Date(timeIntervalSince1970: reset)
    }
}
