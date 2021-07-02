//
//  URLSessionHTTPClientTests.swift
//  TheMovieDBTests
//
//  Created by Tung Vu on 01/07/2021.
//

import XCTest
import TheMovieDB

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.removeStub()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.removeStub()
    }
    
    func test_dispatch_requestsfromURL() {
        let request = makeRequestFrom()
        let sut = makeSUT()
        
        let exp = expectation(description: "wait for completion")
        URLProtocolStub.observeRequests { receivedRequest in
            XCTAssertEqual(request, receivedRequest)
            exp.fulfill()
        }
        
        _ = sut.dispatch(request: request) {_ in}
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_dispatch_failsOnRequestError() {
        let error = NSError(domain: "test", code: 0, userInfo: nil)
        XCTAssertNotNil(errorFor(data: nil, response: nil, error: error))
    }

    func test_dispatch_failsOnAllInvalidRepresentationValues() {
        let nonHTTPURLResponse = nonHTTPURLResponse()
        let anyHTTPURLResponse = anyHTTPResponse()
        let anyData = anyData()
        let anyError = anyNSError()
        
        XCTAssertNotNil(errorFor(data:nil, response: nil, error: nil))
        XCTAssertNotNil(errorFor(data:nil, response: nonHTTPURLResponse, error: nil))
        XCTAssertNotNil(errorFor(data:anyData, response: nil, error: nil))
        XCTAssertNotNil(errorFor(data:anyData, response: nil, error: anyError))
        XCTAssertNotNil(errorFor(data:nil, response: nonHTTPURLResponse, error: anyError))
        XCTAssertNotNil(errorFor(data:nil, response: anyHTTPURLResponse, error: anyError))
        XCTAssertNotNil(errorFor(data:anyData, response: nonHTTPURLResponse, error: anyError))
        XCTAssertNotNil(errorFor(data:anyData, response: anyHTTPURLResponse, error: anyError))
    }
    
    func test_dispatch_succeedsWithEmptyDataOnEmptyDataHTTPURLResponse() {
        let anyHTTPURLResponse = anyHTTPResponse()
        
        let values = valuesFor(data: nil, response: anyHTTPURLResponse, error: nil)
        let emptyData = Data(count: 0)
        XCTAssertEqual(values?.data, emptyData)
        XCTAssertEqual(values?.response.statusCode, anyHTTPURLResponse.statusCode)
        XCTAssertEqual(values?.response.url, anyHTTPURLResponse.url)
    }
    
    func test_dispatch_succeedsOnDataAndHTTPURLResponse() {
        let anyHTTPURLResponse = anyHTTPResponse()
        let anyData = anyData()
        
        let values = valuesFor(data: anyData, response: anyHTTPURLResponse, error: nil)
        XCTAssertEqual(values?.data, anyData)
        XCTAssertEqual(values?.response.statusCode, anyHTTPURLResponse.statusCode)
        XCTAssertEqual(values?.response.url, anyHTTPURLResponse.url)
    }
    
    func test_cancel_cancelsRequest() {
        let sut = makeSUT()

        let exp = expectation(description: "wait for completion")
        let task = sut.dispatch(request: makeRequestFrom()) { result in
            switch result {
            case let .failure(error as NSError) where error.code == URLError.cancelled.rawValue:
                break
            default:
                XCTFail("Expected cancel request but got \(result) instead")
            }
            exp.fulfill()
        }
        
        task.cancel()
        
        wait(for: [exp], timeout: 0.1)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: URL(string: "http://any-url.com")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "http://any-url.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any", code: 0, userInfo: nil)
    }
    
    private func anyData() -> Data {
        Data("any".utf8)
    }
    
    private func valuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        var capturedValues: (data: Data, response: HTTPURLResponse)?
        switch result {
        case let .success((receivedData, receivedResponse)):
            capturedValues = (receivedData, receivedResponse)
        default:
            XCTFail("Expected data and HTTP URL response but got \(String(describing: result)) instead")
        }
        
        return capturedValues
    }
    
    private func errorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        var capturedError: Error?
        switch result {
        case let .failure(error):
            capturedError = error
        default:
            XCTFail("Expected error but got \(String(describing: result)) instead", file: file, line: line)
        }
        
        return capturedError
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.HTTPClientResult? {
        let sut = makeSUT()
        URLProtocolStub.stub(data: data, response: response, error: error)

        let exp = expectation(description: "wait for completion")
        var capturedResult: HTTPClient.HTTPClientResult?
        _ = sut.dispatch(request: makeRequestFrom()) { result in
            capturedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
        return capturedResult
    }

}
