//
//  URLSessionHTTPClient.swift
//  TheMovieDB
//
//  Created by Tung Vu on 02/07/2021.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    private struct InvalidRepresentionValueError: Error {}
    
    private struct WrapperTask: HTTPClientTask {
        var wrapped: URLSessionDataTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    public func dispatch(request: URLRequest, completion: @escaping (HTTPClient.HTTPClientResult) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }
            if let data = data, let response = response as? HTTPURLResponse {
                return completion(.success((data, response)))
            }
            completion(.failure(InvalidRepresentionValueError()))
        }
        
        task.resume()
        
        return WrapperTask(wrapped: task)
    }
}
