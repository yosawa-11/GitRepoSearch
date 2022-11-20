//
//  GithubAPIClient.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import Foundation

final class GithubAPIClient {
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    private let config: GithubAPIConfig
    
    init(
        urlSession: URLSession,
        jsonDecoder: JSONDecoder,
        config: GithubAPIConfig
    ) {
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
        self.config = config
    }
    
    func exec<T: GithubAPIRequest>(request: T, completion: @escaping (Result<T.ResponseType, GithubAPIError>) -> Void) {
        var request = request
        request.token = config.apiToken
        
        let task = urlSession
            .dataTask(with: request.asURLRequest) { [weak self] data, response, error in
                if let error = error {
                    // その他エラー
                    print(error)
                    completion(.failure(.unknown(error)))
                    return
                }
                
                // レート制限に引っかかっているかチェック
                if let httpURLResponse = response as? HTTPURLResponse,
                   httpURLResponse.statusCode == 403,
                   let remainingString = httpURLResponse.value(forHTTPHeaderField: "x-ratelimit-remaining"),
                   Int(remainingString) == 0 {
                    completion(.failure(.rateLimitError))
                    return
                }
                
                guard let data = data,
                      let responseModel = try? self?.jsonDecoder.decode(T.ResponseType.self, from: data) else {
                    completion(.failure(.parseError))
                    return
                }
                
                completion(.success(responseModel))
            }
        
        // データタスクの実行
        task.resume()
    }
}

enum GithubAPIError: Error {
    case parseError
    case rateLimitError
    case unknown(Error?)
}
