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
        viewController?.cellControllers = viewModel.feed.items.map {
            let delegate = NowPlayingItemAdapter<WeakRefVirtualProxy<NowPlayingItemController>, UIImage>(
                imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader),
                model: $0)
            let controller = NowPlayingItemController(delegate: delegate)

            delegate.presenter = NowPlayingItemPresenter(
                imageDataLoadingView: WeakRefVirtualProxy(controller),
                imageDataView: WeakRefVirtualProxy(controller),
                transformer: UIImage.init)
            
            return controller
        }
    }
}

final class NowPlayingItemAdapter<View: ImageDataView, Image>: NowPlayingItemDelegate where View.Image == Image {
    private let imageLoader: MovieImageDataLoader
    var presenter: NowPlayingItemPresenter<View, Image>?
    private let model: NowPlayingCard
    private var task: MovieImageDataTask?
    
    init(imageLoader: MovieImageDataLoader, model: NowPlayingCard){
        self.imageLoader = imageLoader
        self.model = model
    }
    
    func didRequestLoadImageData() {
        presenter?.didStartLoadingImageData()
        task = imageLoader.load(from: makeURL()) { [weak self] result in
            guard let self = self, let data = try? result.get() else {return}
            self.presenter?.didFinishLoadingImageDataSuccessfuly(data)
        }
    }
    
    func didCancelLoadImageData() {
        cancelTask()
    }
    
    private func cancelTask() {
        task?.cancel()
        task = nil
    }
    
    private func makeURL() -> URL {
        let path = model.imagePath
        return URL(string: "https://image.tmdb.org/t/p/w500/\(path)")!
    }
}
