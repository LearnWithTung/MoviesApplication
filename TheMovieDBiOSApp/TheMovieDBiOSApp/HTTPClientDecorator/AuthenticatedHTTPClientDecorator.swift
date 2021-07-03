//
//  AuthenticatedHTTPClientDecorator.swift
//  TheMovieDBiOSApp
//
//  Created by Tung Vu on 03/07/2021.
//

import Foundation
import TheMovieDB

public final class AuthenticatedHTTPClientDecorator: HTTPClient {
    private let decoratee: HTTPClient
    private let credential: Credential
    
    public init(decoratee: HTTPClient, credential: Credential) {
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
    
    public func dispatch(request: URLRequest, completion: @escaping (HTTPClientResult) -> Void) -> HTTPClientTask {
        let decorateeTask = decoratee.dispatch(request: makeRequest(from: request, credential: credential)) { [weak self] result in
            guard self != nil else {return}
            switch result {
            case let .success((data, response)):
                completion(.success((data, response)))
            case let .failure(error):
                completion(.failure(error))
            }
        }
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
