//
//  NowPlayingFeed.swift
//  TheMovieDB
//
//  Created by Tung Vu on 01/07/2021.
//

import Foundation

public struct NowPlayingFeed {
    public let items: [NowPlayingCard]
    public let page: Int
    public let totalPages: Int

    public init(items: [NowPlayingCard], page: Int, totalPages: Int) {
      self.items = items
      self.page = page
      self.totalPages = totalPages
    }
}
