//
//  NowPlayingCard.swift
//  TheMovieDB
//
//  Created by Tung Vu on 01/07/2021.
//

import Foundation

public struct NowPlayingCard: Decodable {
    let id: Int
    let title: String
    let imagePath: String

    init(id: Int, title: String, imagePath: String) {
        self.id = id
        self.title = title
        self.imagePath = imagePath
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case imagePath = "poster_path"
    }
}
