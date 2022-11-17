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
        let task = urlSession
            .dataTask(with: request.asURLRequest) { [weak self] data, response, error in
                print(response)
                
                if let error = error {
                    print(error)
                    completion(.failure(.unknown(error)))
                    return
                }
                
                guard let data = data,
                      let responseModel = try? self?.jsonDecoder.decode(T.ResponseType.self, from: data) else {
                    print("parse error: \(data)")
                    completion(.failure(.parseError))
                    return
                }
                print(String(data: data, encoding: .utf8))
                
                completion(.success(responseModel))
            }
        
        // データタスクの実行
        task.resume()
    }
}

enum GithubAPIError: Error {
    case parseError
    case unknown(Error?)
}
