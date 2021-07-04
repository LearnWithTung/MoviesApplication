//
//  NowPlayingRefreshRepresentationAdapter.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 04/07/2021.
//

import Foundation
import TheMovieDB

final class NowPlayingRefreshRepresentationAdapter: NowPlayingRefreshDelegate {
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
