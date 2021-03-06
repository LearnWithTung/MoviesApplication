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
        viewController?.cellControllers = viewModel.feed.items.compactMap {[weak self] in
            guard let self = self else { return nil}
            return NowPlayingItemCellComposer.controllerComposedWith(model: $0, imageLoader: self.imageLoader)
        }
    }
}
