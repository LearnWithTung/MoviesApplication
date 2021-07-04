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
        let adapter = NowPlayingRefreshRepresentationAdapter(loader: MainQueueDispatchDecorator(decoratee: feedLoader))
        let refreshController = NowPlayingRefreshController(delegate: adapter)
        let viewController = NowPlayingFeedViewController(refreshController: refreshController)
                
        adapter.presenter = NowPlayingRefreshPresenter(loadingView: WeakRefVirtualProxy(refreshController),
                                                       feedView: FeedViewAdapter(viewController: viewController, imageLoader: imageLoader),
                                                       errorView: WeakRefVirtualProxy(viewController))
        
        return viewController
    }
}
