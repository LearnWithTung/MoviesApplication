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

class RemoteNowPlayingFeedLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(query: NowPlayingQuery) {
        let request = URLRequest(url: URL(string: "https://any-url")!)
        client.dispatch(request: request)
    }
}

class LoadNowPlayingFeedFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromRemote() {
        let client = HTTPClientSpy()
        _ = RemoteNowPlayingFeedLoader(client: client)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromRemote() {
        let client = HTTPClientSpy()
        let sut = RemoteNowPlayingFeedLoader(client: client)
        
        sut.load(query: .init(page: 1))
        
        XCTAssertEqual(client.requestedURLs.count, 1)
    }
    
    // MARK: - Helpers
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URLRequest]()
        
        func dispatch(request: URLRequest) {
            requestedURLs.append(request)
        }
    }
    
}
