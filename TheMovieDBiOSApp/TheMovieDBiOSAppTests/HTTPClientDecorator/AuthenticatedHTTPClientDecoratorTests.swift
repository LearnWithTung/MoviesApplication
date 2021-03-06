//
//  AuthenticatedHTTPClientDecoratorTests.swift
//  TheMovieDBiOSAppTests
//
//  Created by Tung Vu on 03/07/2021.
//

import XCTest
import TheMovieDB
import TheMovieDBiOSApp

class AuthenticatedHTTPClientDecoratorTests: XCTestCase {
    
    func test_init_doesNotDispatchRequest() {
        let credential = Credential(apiKey: "any key")
        let (_, client) = makeSUT(credential: credential)
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_dispatch_signsRequestWithAPIKey() {
        let credential = Credential(apiKey: "any_key")
        let (sut, client) = makeSUT(credential: credential)

        let request = URLRequest(url: URL(string: "https://a-url.com")!)
        let expectedRequest = URLRequest(url: URL(string: "https://a-url.com?api_key=\(credential.apiKey)")!)
        _ = sut.dispatch(request: request) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [expectedRequest])
    }
    
    func test_cancel_decorateeCancelLoadingTask() {
        let credential = Credential(apiKey: "any_key")
        let (sut, client) = makeSUT(credential: credential)

        let request = URLRequest(url: URL(string: "https://a-url.com")!)
        let expectedRequest = URLRequest(url: URL(string: "https://a-url.com?api_key=\(credential.apiKey)")!)
        let task = sut.dispatch(request: request) { _ in }
        
        task.cancel()
        
        XCTAssertEqual(client.cancelledURLs, [expectedRequest])
    }
    
    func test_loadCompletion_deliversSuccessOnDecorateeSuccess() {
        let credential = Credential(apiKey: "any_key")
        let data = anyData()
        let request = URLRequest(url: URL(string: "https://a-url.com")!)
        let (sut, client) = makeSUT(credential: credential)
        
        var capturedValues: (Data, HTTPURLResponse)?
        _ = sut.dispatch(request: request) { result in
            switch result {
            case let .success((data, response)):
                capturedValues = (data, response)
            default:
                break
            }
        }
        
        client.completeWith(statusCode: 200, data: data)
        
        XCTAssertEqual(capturedValues?.0, data)
        XCTAssertEqual(capturedValues?.1.statusCode, 200)
    }
    
    func test_loadCompletion_deliversSuccessOnDecorateeFailure() {
        let credential = Credential(apiKey: "any_key")
        let request = URLRequest(url: URL(string: "https://a-url.com")!)
        let (sut, client) = makeSUT(credential: credential)
        
        var capturedError: Error?
        _ = sut.dispatch(request: request) { result in
            switch result {
            case let .failure(error):
                capturedError = error
            default:
                break
            }
        }
        
        client.completeWithError(anyNSError())
        
        XCTAssertNotNil(capturedError)
    }
    
    func test_dispatch_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: AuthenticatedHTTPClientDecorator? = AuthenticatedHTTPClientDecorator(decoratee: client, credential: .init(apiKey: "any"))
        let request = URLRequest(url: URL(string: "https://a-url.com")!)
        
        var capturedResult: HTTPClient.HTTPClientResult?
        _ = sut?.dispatch(request: request) {
            capturedResult = $0
        }
        
        sut = nil
        client.completeWithError(anyNSError())
        
        XCTAssertNil(capturedResult)
    }
    
    // MARK - Helpers
    private func makeSUT(credential: Credential = .init(apiKey: "any"), file: StaticString = #file, line: UInt = #line) -> (sut: AuthenticatedHTTPClientDecorator, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, credential: credential)
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(client, file: file)
        
        return (sut, client)
    }
    
    private func anyData() -> Data {
        Data("any".utf8)
    }
    
    func anyNSError() -> NSError {
        NSError(domain: "any", code: 0, userInfo: nil)
    }

    
    private func checkForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(request: URLRequest, completion: (HTTPClient.HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URLRequest] {
            return messages.map { $0.request }
        }
        
        var cancelledURLs = [URLRequest]()
        
        private struct Task: HTTPClientTask {
            var action: (() -> Void)?
            
            init(action: @escaping () -> Void) {
                self.action = action
            }
            
            func cancel() {
                action?()
            }
        }
        
        func dispatch(request: URLRequest, completion: @escaping (HTTPClient.HTTPClientResult) -> Void)  -> HTTPClientTask {
            messages.append((request, completion))
            
            return Task {[weak self] in self?.cancelTask(url: request)}
        }
        
        private func cancelTask(url: URLRequest) {
            cancelledURLs.append(url)
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
