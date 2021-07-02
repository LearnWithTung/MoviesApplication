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
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    typealias Result = MovieImageDataLoader.Result

    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(from url: URL, completion: @escaping (Result) -> Void) {
        let request = URLRequest(url: url)
        _ = client.dispatch(request: request) { result in
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            case .success:
                completion(.failure(Error.invalidData))
            }
        }
    }
}

class RemoteMovieImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotLoadImageData() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsImageDataFromURL() {
        let (sut, client) = makeSUT()
        
        let url = anyURL()
        sut.load(from: anyURL()) {_ in}
        
        XCTAssertEqual(client.requestedURLs, [URLRequest(url: url)])
    }
    
    func test_loadTwice_requestsImageDataFromURLTwice() {
        let (sut, client) = makeSUT()
        
        let url = anyURL()
        sut.load(from: anyURL()) {_ in}
        sut.load(from: anyURL()) {_ in}
        
        XCTAssertEqual(client.requestedURLs, [URLRequest(url: url), URLRequest(url: url)])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWithError: .connectivity) {
            client.completeWithError(anyNSError())
        }
    }
    
    func test_loadCompletion_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithError: .invalidData) {
                client.completeWith(statusCode: code, data: anyData(), at: index)
            }
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteMovieImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteMovieImageDataLoader(client: client)
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func anyData() -> Data {
        Data("any".utf8)
    }
    
    private func expect(_ sut: RemoteMovieImageDataLoader, toCompleteWithError error: RemoteMovieImageDataLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toCompleteWithResult: .failure(error), when: action, file: file, line: line)
    }
    
    private func expect(_ sut: RemoteMovieImageDataLoader, toCompleteWithResult expectedResult: RemoteMovieImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        
        sut.load(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError as RemoteMovieImageDataLoader.Error), .failure(expectedError as RemoteMovieImageDataLoader.Error)):
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
