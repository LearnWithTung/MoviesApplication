//
//  FeedViewAdapter.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 04/07/2021.
//

import UIKit
import TheMovieDB

final class FeedViewAdapter: FeedView {
    private weak var viewController: NowPlayingFeedViewController?
    private let imageLoader: MovieImageDataLoader
    
    init(viewController: NowPlayingFeedViewController, imageLoader: MovieImageDataLoader) {
        self.viewController = viewController
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        viewController?.cellControllers = viewModel.feed.items.compactMap {[weak self] in self?.controllerComposedWith(model: $0)}
    }
    
    private func controllerComposedWith(model: NowPlayingCard) -> NowPlayingItemController {
        let delegate = NowPlayingItemAdapter<WeakRefVirtualProxy<NowPlayingItemController>, UIImage>(
            imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader),
            model: model)
        let controller = NowPlayingItemController(delegate: delegate)

        delegate.presenter = NowPlayingItemPresenter(
            imageDataLoadingView: WeakRefVirtualProxy(controller),
            imageDataView: WeakRefVirtualProxy(controller),
            transformer: UIImage.init)

        return controller
    }
}
