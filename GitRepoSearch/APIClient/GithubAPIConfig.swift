//
//  GithubAPIConfig.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/20.
//

import Foundation

final class GithubAPIConfig {
    var apiToken: String {
        configPlist["GithubAPIToken"] as? String ?? { fatalError("GithubAPITokenが未定義") }()
    }
    
    private var configPlist: [String: Any] {
        guard let url = Bundle.main.url(forResource: "config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dictionary = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            fatalError("config.plistが見つからない")
        }
        return dictionary
    }
}
