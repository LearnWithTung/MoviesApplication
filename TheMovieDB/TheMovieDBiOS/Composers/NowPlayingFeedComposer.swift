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
                
        adapter.presenter = NowPlayingRefreshPresenter(loadingView: refreshController,
                                                       feedView: FeedViewAdapter(viewController: viewController, imageLoader: imageLoader),
                                                       errorView: viewController)
        
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

private class FeedViewAdapter: FeedView {
    private weak var viewController: NowPlayingFeedViewController?
    private let imageLoader: MovieImageDataLoader
    
    init(viewController: NowPlayingFeedViewController, imageLoader: MovieImageDataLoader) {
        self.viewController = viewController
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        viewController?.cellControllers = viewModel.feed.items.map {
            let viewModel = NowPlayingItemViewModel(model: $0, imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader), transformer: UIImage.init)
            return NowPlayingItemController(viewModel: viewModel)
        }
    }
}

private class NowPlayingRefreshRepresentationAdapter: NowPlayingRefreshDelegate {
    private let loader: NowPlayingLoader
    var presenter: NowPlayingRefreshPresenter?
    
    init(loader: NowPlayingLoader) {
        self.loader = loader
    }
    
    
    func didRequestRefreshFeed() {
        presenter?.didStartLoadingFeed()
        loader.load(query: .init(page: 1)) {[weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeedSuccessfully(feed)
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeedWithError(error)
            }
        }
    }
    
}
