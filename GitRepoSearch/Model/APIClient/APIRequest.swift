//
//  APIRequest.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import Foundation

protocol APIRequest {
    var host: String { get }
    var schema: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var httpHeader: [String: String] { get }
    var encoding: Encoding { get }
    var parameters: [String: Any] { get }
}

extension APIRequest {
    var asURLRequest: URLRequest {
        let baseURL = URL(string: "\(schema)://\(host)/\(path)") ?? { fatalError("BaseURL生成失敗") }()
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)

        switch encoding {
        case .URLEncoding:
            components?.queryItems = parameters.compactMap {
                switch $0.value {
                case is String:
                    return URLQueryItem(name: $0.key, value: ($0.value as? String)?.urlEncoded)
                case is NSNumber:
                    return URLQueryItem(name: $0.key, value: ($0.value as? NSNumber)?.stringValue)
                default:
                    return nil
                }
            }
        }
        
        let url = components?.url ?? { fatalError("URLComponentsからURL生成失敗") }()
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = httpHeader
        
        return urlRequest
    }
}

enum HTTPMethod: String {
    // 最低限のためGETのみ実装
    case get = "GET"
}

enum Encoding {
    // 最低限のためURLエンコードのみ実装
    case URLEncoding
}

private extension String {
    var urlEncoded: String? {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
