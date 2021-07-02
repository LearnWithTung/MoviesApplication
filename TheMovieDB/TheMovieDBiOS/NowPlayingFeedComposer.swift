//
//  NowPlayingFeedComposer.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 02/07/2021.
//

import Foundation
import TheMovieDB

public class NowPlayingFeedComposer {
    
    public static func viewControllerComposedWith(feedLoader: NowPlayingLoader, imageLoader: MovieImageDataLoader) -> NowPlayingFeedViewController {
        let refreshController = NowPlayingRefreshController(loader: feedLoader)
        return NowPlayingFeedViewController(refreshController: refreshController, imageLoader: imageLoader)
    }
}
