//
//  RemoteNowPlayingFeedLoader.swift
//  TheMovieDB
//
//  Created by Tung Vu on 01/07/2021.
//

import Foundation

public protocol HTTPClient {
    func dispatch(request: URLRequest)
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
    
    public func load(query: NowPlayingQuery) {
        let request = makeRequestWith(query: query)
        client.dispatch(request: request)
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
