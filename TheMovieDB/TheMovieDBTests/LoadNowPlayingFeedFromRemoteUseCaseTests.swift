//
//  LoadNowPlayingFeedFromRemoteUseCaseTests.swift
//  TheMovieDBTests
//
//  Created by Tung Vu on 01/07/2021.
//

import XCTest
import TheMovieDB

protocol HTTPClient {
    func dispatch(request: URLRequest)
}

struct Credential {
    let apiKey: String
}

class RemoteNowPlayingFeedLoader {
    private let url: URL
    private let credential: Credential
    private let client: HTTPClient
    
    init(url: URL, credential: Credential, client: HTTPClient) {
        self.url = url
        self.credential = credential
        self.client = client
    }
    
    func load(query: NowPlayingQuery) {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: credential.apiKey),
            URLQueryItem(name: "page", value: "\(query.page)")
        ]
        
        let request = URLRequest(url: components.url!)
        client.dispatch(request: request)
    }
}

class LoadNowPlayingFeedFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromRemote() {
        let url = URL(string: "http://any-url.com")!
        let credential = Credential(apiKey: "any key")
        let client = HTTPClientSpy()
        _ = RemoteNowPlayingFeedLoader(url: url, credential: credential, client: client)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromRemote() {
        let url = URL(string: "http://a-url.com")!
        let credential = Credential(apiKey: "a key")
        let page = 1
        let client = HTTPClientSpy()
        let sut = RemoteNowPlayingFeedLoader(url: url, credential: credential, client: client)
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: credential.apiKey),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        let expectedRequest = URLRequest(url: components.url!)
        
        sut.load(query: .init(page: page))
        
        XCTAssertEqual(client.requestedURLs, [expectedRequest])
    }
    
    // MARK: - Helpers
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URLRequest]()
        
        func dispatch(request: URLRequest) {
            requestedURLs.append(request)
        }
    }
    
}
