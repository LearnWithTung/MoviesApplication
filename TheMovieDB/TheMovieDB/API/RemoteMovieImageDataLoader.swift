//
//  RemoteMovieImageDataLoader.swift
//  TheMovieDB
//
//  Created by Tung Vu on 02/07/2021.
//

import Foundation

public final class RemoteMovieImageDataLoader {
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = MovieImageDataLoader.Result

    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func load(from url: URL, completion: @escaping (Result) -> Void) -> MovieImageDataTask {
        let request = URLRequest(url: url)
        let wrapper = HTTPClientTaskWrapper(completion)
        wrapper.task = client.dispatch(request: request) { result in
            wrapper.completeWith(result
                            .mapError {_ in Error.connectivity}
                            .flatMap { data, response in
                guard response.statusCode == 200 else {
                    return .failure(Error.invalidData)
                }
                return .success(data)
            })
        }
        
        return wrapper
    }
}

final class HTTPClientTaskWrapper: MovieImageDataTask {
    var task: HTTPClientTask?
    private var completion: ((RemoteMovieImageDataLoader.Result) -> Void)?
    
    init(_ completion: @escaping (RemoteMovieImageDataLoader.Result) -> Void) {
        self.completion = completion
    }
    
    func completeWith(_ result: RemoteMovieImageDataLoader.Result) {
        completion?(result)
    }
    
    public func cancel() {
        task?.cancel()
        preventFurtherCompletion()
    }
    
    private func preventFurtherCompletion() {
        completion = nil
    }
}
