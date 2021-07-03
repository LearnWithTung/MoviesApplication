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
        let refreshController = NowPlayingRefreshController(loader: MainQueueDispatchDecorator(decoratee: feedLoader))
        let viewController = NowPlayingFeedViewController(refreshController: refreshController)
        
        refreshController.onRefresh = adaptCellControllers(from: viewController,
                                                           and: imageLoader)
        
        return viewController
    }
    
    private static func adaptCellControllers(from viewController: NowPlayingFeedViewController, and loader: MovieImageDataLoader) -> (NowPlayingFeed) -> Void{
        {[weak viewController] feed in
            viewController?.cellControllers = feed.items.map {
                NowPlayingItemController(model: $0,
                                         imageLoader: MainQueueDispatchDecorator(decoratee: loader))
                
            }
        }
    }
}

extension MainQueueDispatchDecorator: MovieImageDataLoader where T == MovieImageDataLoader {
    public func load(from url: URL, completion: @escaping (MovieImageDataLoader.Result) -> Void) -> MovieImageDataTask {
        decoratee.load(from: url) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}


extension MainQueueDispatchDecorator: NowPlayingLoader where T == NowPlayingLoader {
    public func load(query: NowPlayingQuery, completion: @escaping (NowPlayingLoader.Result) -> Void) {
        decoratee.load(query: query) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}
