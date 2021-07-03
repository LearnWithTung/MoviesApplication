//
//  AuthenticatedHTTPClientDecoratorTests.swift
//  TheMovieDBiOSAppTests
//
//  Created by Tung Vu on 03/07/2021.
//

import XCTest
import TheMovieDB

class AuthenticatedHTTPClientDecorator: HTTPClient {
    private let decoratee: HTTPClient
    private let credential: Credential
    
    init(decoratee: HTTPClient, credential: Credential) {
        self.decoratee = decoratee
        self.credential = credential
    }
    private struct DecoratedTask: HTTPClientTask {
        private let decorateeTask: HTTPClientTask
        
        init(decorateeTask: HTTPClientTask) {
            self.decorateeTask = decorateeTask
        }
        
        func cancel() {
            decorateeTask.cancel()
        }
    }
    
    func dispatch(request: URLRequest, completion: @escaping (HTTPClientResult) -> Void) -> HTTPClientTask {
        let decorateeTask = decoratee.dispatch(request: makeRequest(from: request, credential: credential)) { _ in }
        return DecoratedTask(decorateeTask: decorateeTask)
    }
    
    private func makeRequest(from original: URLRequest, credential: Credential) -> URLRequest {
        guard let requestURL = original.url, var components = URLComponents(url: requestURL, resolvingAgainstBaseURL: false) else {return original}
        let queriesItem = components.queryItems ?? []
        let decoratedQuery = URLQueryItem(name: "api_key", value: credential.apiKey)
        
        components.queryItems = queriesItem + [decoratedQuery]
        
        guard let authenticatedRequestURL = components.url else { return original }

        var signedRequest = original
        signedRequest.url = authenticatedRequestURL
        return signedRequest
    }

}

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
    
    // MARK - Helpers
    private func makeSUT(credential: Credential = .init(apiKey: "any"), file: StaticString = #file, line: UInt = #line) -> (sut: AuthenticatedHTTPClientDecorator, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, credential: credential)
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(client, file: file)
        
        return (sut, client)
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
