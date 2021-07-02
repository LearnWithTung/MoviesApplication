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
        let viewController = NowPlayingFeedViewController(refreshController: refreshController)
        
        refreshController.onRefresh = adaptCellControllers(from: viewController, and: imageLoader)
        
        return viewController
    }
    
    private static func adaptCellControllers(from viewController: NowPlayingFeedViewController, and loader: MovieImageDataLoader) -> (NowPlayingFeed) -> Void{
        {[weak viewController] feed in
            viewController?.cellControllers = feed.items.map {NowPlayingItemController(model: $0, imageLoader: loader)}
        }
    }
}
