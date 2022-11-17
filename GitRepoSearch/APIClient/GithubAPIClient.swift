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
    
    init(
        urlSession: URLSession,
        jsonDecoder: JSONDecoder
    ) {
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
    }
    
    func exec<T: GithubAPIRequest>(request: T, completion: @escaping (Result<T.ResponseType, GithubAPIError>) -> Void) {
        // TODO: 本来はベタ書きをやめてconfigをClientに注入した上でそこから読み取る
        var request = request
        request.token = "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"
        
        let task = urlSession
            .dataTask(with: request.asURLRequest) { [weak self] data, response, error in
                print(response)
                
                if let error = error {
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
