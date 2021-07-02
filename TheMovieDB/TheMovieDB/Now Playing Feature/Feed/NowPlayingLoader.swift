//
//  NowPlayingLoader.swift
//  TheMovieDB
//
//  Created by Tung Vu on 01/07/2021.
//

import Foundation

public struct NowPlayingQuery: Equatable {
    public let page: Int

    public init(page: Int) {
      self.page = page
    }
}

public protocol NowPlayingLoader {
    typealias Result = Swift.Result<NowPlayingFeed, Error>
    func load(query: NowPlayingQuery, completion: @escaping (Result) -> Void)
}
