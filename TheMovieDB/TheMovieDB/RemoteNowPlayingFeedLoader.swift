//
//  RemoteNowPlayingFeedLoader.swift
//  TheMovieDB
//
//  Created by Tung Vu on 01/07/2021.
//

import Foundation

public protocol HTTPClient {
    typealias HTTPClientResult = Result<(data: Data, response: HTTPURLResponse), Error>
    func dispatch(request: URLRequest, completion: @escaping (HTTPClientResult) -> Void)
}

public struct Credential {
    public let apiKey: String
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
}

public class RemoteNowPlayingFeedLoader {
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
    
    public func load(query: NowPlayingQuery, completion: @escaping (Result<NowPlayingFeed, Error>) -> Void = {_ in}) {
        let request = makeRequestWith(query: query)
        client.dispatch(request: request) { result in
            switch result {
            case let .success((data, _)):
                if let feed = try? JSONDecoder().decode(NowPlayingFeed.self, from: data) {
                    return completion(.success(feed))
                }
                completion(.failure(.invalidData))
            case .failure:
                completion(.failure(.connectivity))
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

