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
        let clientError = NSError(domain: "test", code: 0, userInfo: nil)
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .connectivity) {
            client.completeWithError(clientError)
        }
    }
    
    func test_loadCompletion_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithError: .invalidData) {
                client.completeWith(statusCode: code, at: index)
            }
        }
    }
    
    func test_loadCompletion_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let invalidJSON = Data("invalid json".utf8)
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .invalidData) {
            client.completeWith(statusCode: 200, data: invalidJSON)
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!, credential: Credential = .init(apiKey: "any")) -> (sut: RemoteNowPlayingFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteNowPlayingFeedLoader(url: url, credential: credential, client: client)
        
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteNowPlayingFeedLoader, toCompleteWithError error: RemoteNowPlayingFeedLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        var capturedError: RemoteNowPlayingFeedLoader.Error?
        
        sut.load(query: .init(page: 1)) {
            capturedError = $0
            exp.fulfill()
        }
    
        action()
        
        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(capturedError, error, file: file, line: line)
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
        private var messages = [(request: URLRequest, completion: (HTTPClient.HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URLRequest] {
            return messages.map { $0.request }
        }
        
        func dispatch(request: URLRequest, completion: @escaping (HTTPClient.HTTPClientResult) -> Void) {
            messages.append((request, completion))
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
