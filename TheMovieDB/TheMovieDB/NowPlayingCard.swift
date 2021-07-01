//
//  NowPlayingCard.swift
//  TheMovieDB
//
//  Created by Tung Vu on 01/07/2021.
//

import Foundation

public struct NowPlayingCard {
    public let id: Int
    public let title: String
    public let imagePath: String

    public init(id: Int, title: String, imagePath: String) {
        self.id = id
        self.title = title
        self.imagePath = imagePath
    }
}
