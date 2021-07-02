//
//  MovieImageDataLoader.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 02/07/2021.
//

import Foundation

public protocol MovieImageDataTask {
    func cancel()
}

public protocol MovieImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func load(from url: URL, completion: @escaping (Result) -> Void) -> MovieImageDataTask
}
