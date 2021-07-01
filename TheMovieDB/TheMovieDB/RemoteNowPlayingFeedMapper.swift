//
//  RemoteNowPlayingFeedMapper.swift
//  TheMovieDB
//
//  Created by Tung Vu on 01/07/2021.
//

import Foundation

class RemoteNowPlayingFeedMapper {
    private struct Root: Decodable {
        let page: Int
        let total_pages: Int
        let results: [RemoteNowPlayingCard]
        
        struct RemoteNowPlayingCard: Decodable {
            let id: Int
            let title: String
            let poster_path: String
            
            var model: NowPlayingCard {
                return NowPlayingCard(id: id, title: title, imagePath: poster_path)
            }
        }
        
        var feed: NowPlayingFeed {
            return NowPlayingFeed(items: results.map {$0.model}, page: page, totalPages: total_pages)
        }
    }

    static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteNowPlayingFeedLoader.Result {
        if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
            return .success(root.feed)
        }
        return .failure(.invalidData)
    }
}
