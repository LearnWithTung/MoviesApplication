//
//  LoadNowPlayingFeedFromRemoteUseCaseTests.swift
//  TheMovieDBTests
//
//  Created by Tung Vu on 01/07/2021.
//

import XCTest

protocol HTTPClient {
    func dispatch(request: URLRequest)
}

class RemoteNowPlayingFeedLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
}

class LoadNowPlayingFeedFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromRemote() {
        let client = HTTPClientSpy()
        _ = RemoteNowPlayingFeedLoader(client: client)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    // MARK: - Helpers
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URLRequest]()
        
        func dispatch(request: URLRequest) {
            
        }
    }
    
}
