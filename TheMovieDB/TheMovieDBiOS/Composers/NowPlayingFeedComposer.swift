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
        let adapter = NowPlayingRefreshRepresentationAdapter(loader: MainQueueDispatchDecorator(decoratee: feedLoader))
        let refreshController = NowPlayingRefreshController(delegate: adapter)
        let viewController = NowPlayingFeedViewController(refreshController: refreshController)
                
        adapter.presenter = NowPlayingRefreshPresenter(loadingView: WeakRefVirtualProxy(refreshController),
                                                       feedView: FeedViewAdapter(viewController: viewController, imageLoader: imageLoader),
                                                       errorView: WeakRefVirtualProxy(viewController))
        
        return viewController
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
