//
//  TestsHelpers.swift
//  TheMovieDBTests
//
//  Created by Tung Vu on 01/07/2021.
//

import Foundation
import TheMovieDB

func makeRequestFrom(url: URL = URL(string: "http://any-url.com")!, page: Int = 1) -> URLRequest {
    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
    components.queryItems = [
        URLQueryItem(name: "page", value: "\(page)")
    ]
    
    return URLRequest(url: components.url!)
}

func uniqueNowPlayingCard(id: Int = 0) -> NowPlayingCard {
    return NowPlayingCard(id: id, title: "\(UUID().uuidString) title", imagePath: "/\(UUID().uuidString)_image_path.jpg")
}
    
func anyNSError() -> NSError {
    NSError(domain: "any", code: 0, userInfo: nil)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

func anyData() -> Data {
    Data("any".utf8)
}
