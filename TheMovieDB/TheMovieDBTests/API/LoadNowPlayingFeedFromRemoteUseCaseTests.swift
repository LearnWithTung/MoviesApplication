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
        let page = 1
        let expectedRequest = makeRequestFrom(url: url, page: page)
        let (sut, client) = makeSUT(url: url)
        
        sut.load(query: .init(page: page)) {_ in}
        
        XCTAssertEqual(client.requestedURLs, [expectedRequest])
    }
    
    func test_loadTwice_requestsDataFromRemoteTwice() {
        let url = URL(string: "http://a-url.com")!
        let page = 1
        let expectedRequest = makeRequestFrom(url: url, page: page)
        let (sut, client) = makeSUT(url: url)
        
        sut.load(query: .init(page: page)) {_ in}
        sut.load(query: .init(page: page)) {_ in}
        
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
                let emptyResponse = makeNowPlayingFeed(cards: [], page: 1, totalPages: 1)
                let emptyJSON = makeFeedJSON(emptyResponse.json)
                client.completeWith(statusCode: code, data: emptyJSON, at: index)
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
        
        expect(sut, toCompleteWithFeed: emptyResponse.model) {
            client.completeWith(statusCode: 200, data: emptyJSON)
        }
    }
    
    func test_loadCompletion_deliversNowPlayingFeedOn200HTTPResponseWithJSONFeed() {
        let cards = (0...5).map {uniqueNowPlayingCard(id: $0)}
        let feed = makeNowPlayingFeed(cards: cards, page: 1, totalPages: 1)
        let json = makeFeedJSON(feed.json)
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithFeed: feed.model) {
            client.completeWith(statusCode: 200, data: json)
        }
    }
    
    func test_loadCompletion_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteNowPlayingFeedLoader? = RemoteNowPlayingFeedLoader(url: URL(string: "http://any-url.com")!,
                                                                          client: client)
        
        var capturedResult: RemoteNowPlayingFeedLoader.Result?
        sut?.load(query: .init(page: 1)) {capturedResult = $0}
        
        sut = nil
        client.completeWithError(NSError(domain: "test", code: 0, userInfo: nil))
        
        XCTAssertNil(capturedResult)
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteNowPlayingFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteNowPlayingFeedLoader(url: url, client: client)
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func makeNowPlayingFeed(cards: [NowPlayingCard], page: Int = 1, totalPages: Int = 1) -> (model: NowPlayingFeed, json: [String: Any]){
        let model = NowPlayingFeed(items: cards, page: page, totalPages: totalPages)
        
        var results = [Dictionary<String, Any>]()
        
        cards.forEach {
            let json: [String : Any] = [
                "id": $0.id,
                "title": $0.title,
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
    
    private func expect(_ sut: RemoteNowPlayingFeedLoader, toCompleteWithFeed expectedFeed: NowPlayingFeed, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toCompleteWithResult: .success(expectedFeed), when: action, file: file, line: line)
    }
    
    private func expect(_ sut: RemoteNowPlayingFeedLoader, toCompleteWithError error: RemoteNowPlayingFeedLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toCompleteWithResult: .failure(error), when: action, file: file, line: line)
    }
    
    private func expect(_ sut: RemoteNowPlayingFeedLoader, toCompleteWithResult expectedResult: RemoteNowPlayingFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        
        sut.load(query: .init(page: 1)) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError as RemoteNowPlayingFeedLoader.Error), .failure(expectedError as RemoteNowPlayingFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) but got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
    
        action()
        
        wait(for: [exp], timeout: 0.1)
    }
    
}
