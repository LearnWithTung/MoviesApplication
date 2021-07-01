//
//  LoadNowPlayingFeedFromRemoteUseCaseTests.swift
//  TheMovieDBTests
//
//  Created by Tung Vu on 01/07/2021.
//

import XCTest
import TheMovieDB

class LoadNowPlayingFeedFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromRemote() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromRemote() {
        let url = URL(string: "http://a-url.com")!
        let credential = Credential(apiKey: "a key")
        let page = 1
        let expectedRequest = makeRequestFrom(credential: credential, url: url, page: page)
        let (sut, client) = makeSUT(url: url, credential: credential)
        
        sut.load(query: .init(page: page))
        
        XCTAssertEqual(client.requestedURLs, [expectedRequest])
    }
    
    func test_loadTwice_requestsDataFromRemoteTwice() {
        let url = URL(string: "http://a-url.com")!
        let credential = Credential(apiKey: "a key")
        let page = 1
        let expectedRequest = makeRequestFrom(credential: credential, url: url, page: page)
        let (sut, client) = makeSUT(url: url, credential: credential)
        
        sut.load(query: .init(page: page))
        sut.load(query: .init(page: page))
        
        XCTAssertEqual(client.requestedURLs, [expectedRequest, expectedRequest])
    }
    
    func test_loadCompletion_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedError: RemoteNowPlayingFeedLoader.Error?
        sut.load(query: .init(page: 1)) { capturedError = $0 }
        
        let clientError = NSError(domain: "test", code: 0, userInfo: nil)
        client.completeWithError(clientError)
        
        XCTAssertEqual(capturedError, .connectivity)
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!, credential: Credential = .init(apiKey: "any")) -> (sut: RemoteNowPlayingFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteNowPlayingFeedLoader(url: url, credential: credential, client: client)
        
        return (sut, client)
    }
    
    private func makeRequestFrom(credential: Credential, url: URL, page: Int) -> URLRequest {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: credential.apiKey),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        return URLRequest(url: components.url!)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URLRequest]()
        var completions = [(Error) -> Void]()
        
        func dispatch(request: URLRequest, completion: @escaping (Error) -> Void) {
            requestedURLs.append(request)
            completions.append(completion)
        }
        
        func completeWithError(_ error: Error, at index: Int = 0) {
            completions[index](error)
        }
    }
    
}
