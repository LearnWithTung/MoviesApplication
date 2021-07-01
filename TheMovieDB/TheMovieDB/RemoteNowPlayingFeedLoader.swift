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
    
    public typealias Result = Swift.Result<NowPlayingFeed, Error>
    
    public func load(query: NowPlayingQuery, completion: @escaping (Result) -> Void = {_ in}) {
        let request = makeRequestWith(query: query)
        client.dispatch(request: request) {[weak self] result in
            guard let self = self else {return}
            switch result {
            case let .success((data, response)):
                completion(self.map(response, data: data))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    private func map(_ response: HTTPURLResponse, data: Data) -> Result {
        if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
            return .success(root.feed)
        }
        return .failure(.invalidData)
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

private struct Root: Decodable {
    let page: Int
    let total_pages: Int
    let results: [RemoteNowPlayingCard]
    
    struct RemoteNowPlayingCard: Decodable {
        let id: Int
        let title: String
        let poster_path: String
        
        var model: NowPlayingCard {
            return NowPlayingCard(id: id, title: title, imagePath: poster_path)
        }
    }
    
    var feed: NowPlayingFeed {
        return NowPlayingFeed(items: results.map {$0.model}, page: page, totalPages: total_pages)
    }
}
