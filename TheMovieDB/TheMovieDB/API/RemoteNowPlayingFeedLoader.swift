//
//  RemoteNowPlayingFeedLoader.swift
//  TheMovieDB
//
//  Created by Tung Vu on 01/07/2021.
//

import Foundation

public class RemoteNowPlayingFeedLoader: NowPlayingLoader {
    private let url: URL
    private let credential: Credential
    private let client: HTTPClient
    
    public init(url: URL, credential: Credential, client: HTTPClient) {
        self.url = url
        self.credential = credential
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = NowPlayingLoader.Result
    
    public func load(query: NowPlayingQuery, completion: @escaping (Result) -> Void) {
        let request = makeRequestWith(query: query)
        _ = client.dispatch(request: request) {[weak self] result in
            guard self != nil else {return}
            switch result {
            case let .success((data, response)):
                completion(RemoteNowPlayingFeedMapper.map(data, response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private func makeRequestWith(query: NowPlayingQuery) -> URLRequest {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: credential.apiKey),
            URLQueryItem(name: "page", value: "\(query.page)")
        ]
        
        return URLRequest(url: components.url!)
    }
}
