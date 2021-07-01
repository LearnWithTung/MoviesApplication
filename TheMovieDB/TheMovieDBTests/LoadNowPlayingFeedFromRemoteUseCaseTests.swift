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
    
    func test_loadCompletion_deliversEmptyOn200HTTPResponseWithEmptyJSONPage() {
        let emptyResponse = makeNowPlayingFeed(cards: [], page: 1, totalPages: 1)
        let emptyJSON = makeFeedJSON(emptyResponse.json)
        
        let (sut, client) = makeSUT()
        
        let exp = expectation(description: "wait for completion")
        sut.load(query: .init(page: 1)) { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed.page, 1)
                XCTAssertEqual(feed.totalPages, 1)
                XCTAssertTrue(feed.items.isEmpty)
            default:
                XCTFail("Expected empty page but got \(result) instead")
            }
            exp.fulfill()
        }
        
        client.completeWith(statusCode: 200, data: emptyJSON)
        wait(for: [exp], timeout: 0.1)
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!, credential: Credential = .init(apiKey: "any")) -> (sut: RemoteNowPlayingFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteNowPlayingFeedLoader(url: url, credential: credential, client: client)
        
        return (sut, client)
    }
    
    private func makeNowPlayingFeed(cards: [NowPlayingCard], page: Int = 1, totalPages: Int = 1) -> (model: NowPlayingFeed, json: [String: Any]){
        let model = NowPlayingFeed(items: cards, page: page, totalPages: totalPages)
        
        var results = [Dictionary<String, Any>]()
        
        cards.forEach {
            let json: [String : Any] = [
                "id": $0.id,
                "title:": $0.title,
                "poster_path": $0.imagePath
            ]
            results.append(json)
        }
        
        let feedJSON: [String : Any] = [
            "page": 1,
            "total_pages": 1,
            "results": results
        ]
        
        return (model, feedJSON)
    }
    
    private func makeFeedJSON(_ dict: [String: Any]) -> Data {
        try! JSONSerialization.data(withJSONObject: dict)
    }
    
    private func expect(_ sut: RemoteNowPlayingFeedLoader, toCompleteWithError error: RemoteNowPlayingFeedLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        var capturedError: RemoteNowPlayingFeedLoader.Error?
        
        sut.load(query: .init(page: 1)) { result in
            switch result {
            case let .failure(error):
                capturedError = error
            default:
                XCTFail("Expected error but got \(result) instead", file: file, line: line)
            }
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
