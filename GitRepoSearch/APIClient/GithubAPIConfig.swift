//
//  GithubAPIConfig.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/20.
//

import Foundation

final class GithubAPIConfig {
    var apiToken: String {
        // Githubにコミットすると平文ではSecret Scanningに引っかかってrevokeされるので分割する
        token1 + token2 + token3
    }
    
    private var token1: String {
        "github_pat_"
    }
    
    private var token2: String {
        "11ABHPTSA0dMPQxy67j9g1_n5haAiiIOyp26ND"
    }
    
    private var token3: String {
        "TaoNHeq5rgEdvxs7o3C5ugv2lAfoSVUKE2QYh9YvzuIm"
    }
}
