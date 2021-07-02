//
//  HTTPClientSpy.swift
//  TheMovieDBTests
//
//  Created by Tung Vu on 02/07/2021.
//

import Foundation
import TheMovieDB

class HTTPClientSpy: HTTPClient {
    
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
