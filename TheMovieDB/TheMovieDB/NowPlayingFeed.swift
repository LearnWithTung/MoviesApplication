//
//  NowPlayingFeed.swift
//  TheMovieDB
//
//  Created by Tung Vu on 01/07/2021.
//

import Foundation

struct NowPlayingFeed {
    let items: [NowPlayingCard]
    let page: Int
    let totalPages: Int

    init(items: [NowPlayingCard], page: Int, totalPages: Int) {
      self.items = items
      self.page = page
      self.totalPages = totalPages
    }
}
