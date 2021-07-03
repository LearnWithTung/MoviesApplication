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
    private struct Task: HTTPClientTask {
        func cancel() {}
    }
    
    func dispatch(request: URLRequest, completion: @escaping (HTTPClientResult) -> Void) -> HTTPClientTask {
        _ = decoratee.dispatch(request: makeRequest(from: request, credential: credential)) { _ in }
        return Task()
    }
    
    private func makeRequest(from original: URLRequest, credential: Credential) -> URLRequest {
        guard let requestURL = original.url, var components = URLComponents(url: requestURL, resolvingAgainstBaseURL: false) else {return original}
        let queriesItem = components.queryItems ?? []
        let decoratedQuery = URLQueryItem(name: "api_key", value: credential.apiKey)
        
        components.queryItems = queriesItem + [decoratedQuery]
        
        return components.url == nil ? original : URLRequest(url: components.url!)
    }

}

class AuthenticatedHTTPClientDecoratorTests: XCTestCase {
    
    func test_init_doesNotDispatchRequest() {
        let client = HTTPClientSpy()
        let credential = Credential(apiKey: "any key")
        _ = AuthenticatedHTTPClientDecorator(decoratee: client, credential: credential)
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_dispatch_signsRequestWithAPIKey() {
        let client = HTTPClientSpy()
        let credential = Credential(apiKey: "any_key")
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, credential: credential)
        
        let request = URLRequest(url: URL(string: "https://a-url.com")!)
        let expectedRequest = URLRequest(url: URL(string: "https://a-url.com?api_key=any_key")!)
        _ = sut.dispatch(request: request) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [expectedRequest])
    }
    
    // MARK - Helpers
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(request: URLRequest, completion: (HTTPClient.HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URLRequest] {
            return messages.map { $0.request }
        }
        
        var cancelledURLs = [URL]()
        
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
            
            return Task {[weak self] in self?.cancelTask(url: request.url!)}
        }
        
        private func cancelTask(url: URL) {
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
