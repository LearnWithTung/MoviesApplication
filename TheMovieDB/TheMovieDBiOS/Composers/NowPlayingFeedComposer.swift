//
//  NowPlayingFeedComposer.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 02/07/2021.
//

import Foundation
import TheMovieDB
import UIKit

public class NowPlayingFeedComposer {
    public static func viewControllerComposedWith(feedLoader: NowPlayingLoader, imageLoader: MovieImageDataLoader) -> NowPlayingFeedViewController {
        let viewModel = NowPlayingRefreshViewModel(loader: MainQueueDispatchDecorator(decoratee: feedLoader))
        let refreshController = NowPlayingRefreshController(viewModel: viewModel)
        let viewController = NowPlayingFeedViewController(refreshController: refreshController)
        
        viewModel.onLoadFeed = adaptCellControllers(from: viewController,
                                                           and: imageLoader)
        
        return viewController
    }
    
    private static func adaptCellControllers(from viewController: NowPlayingFeedViewController, and loader: MovieImageDataLoader) -> (NowPlayingFeed) -> Void{
        {[weak viewController] feed in
            viewController?.cellControllers = feed.items.map {
                let viewModel = NowPlayingItemViewModel(model: $0, imageLoader: loader, transformer: UIImage.init)
                return NowPlayingItemController(viewModel: viewModel)
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
