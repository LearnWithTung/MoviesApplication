//
//  NowPlayingItemCellComposer.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 04/07/2021.
//

import UIKit
import TheMovieDB

final class NowPlayingItemCellComposer {
    private init() {}
    
    static func controllerComposedWith(model: NowPlayingCard, imageLoader: MovieImageDataLoader) -> NowPlayingItemController {
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
