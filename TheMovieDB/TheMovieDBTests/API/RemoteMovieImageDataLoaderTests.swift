//
//  RemoteMovieImageDataLoaderTests.swift
//  TheMovieDBTests
//
//  Created by Tung Vu on 02/07/2021.
//

import XCTest
import TheMovieDB

class RemoteMovieImageDataLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(from url: URL) {
        let request = URLRequest(url: url)
        _ = client.dispatch(request: request) { _ in}
    }
}

class RemoteMovieImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotLoadImageData() {
        let client = HTTPClientSpy()
        _ = RemoteMovieImageDataLoader(client: client)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsImageDataFromURL() {
        let client = HTTPClientSpy()
        let sut = RemoteMovieImageDataLoader(client: client)
        
        let url = anyURL()
        sut.load(from: anyURL())
        
        XCTAssertEqual(client.requestedURLs, [URLRequest(url: url)])
    }
    
    func test_loadTwice_requestsImageDataFromURLTwice() {
        let client = HTTPClientSpy()
        let sut = RemoteMovieImageDataLoader(client: client)
        
        let url = anyURL()
        sut.load(from: anyURL())
        sut.load(from: anyURL())
        
        XCTAssertEqual(client.requestedURLs, [URLRequest(url: url), URLRequest(url: url)])
    }
    
    // MARK: - Helpers
}
