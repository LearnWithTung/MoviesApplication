//
//  HTTPClient.swift
//  TheMovieDB
//
//  Created by Tung Vu on 01/07/2021.
//

import Foundation

public protocol HTTPClient {
    typealias HTTPClientResult = Result<(data: Data, response: HTTPURLResponse), Error>
    func dispatch(request: URLRequest, completion: @escaping (HTTPClientResult) -> Void)
}
