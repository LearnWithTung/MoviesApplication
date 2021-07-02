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
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(request: URLRequest, completion: (HTTPClient.HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URLRequest] {
            return messages.map { $0.request }
        }
        
        private struct Task: HTTPClientTask {
            func cancel() {}
        }
        
        func dispatch(request: URLRequest, completion: @escaping (HTTPClient.HTTPClientResult) -> Void)  -> HTTPClientTask {
            messages.append((request, completion))
            
            return Task()
        }
        
        func completeWithError(_ error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func completeWith(statusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let httpResponse = HTTPURLResponse(url: requestedURLs[index].url!, statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data, httpResponse)))
        }
        
    }
}
