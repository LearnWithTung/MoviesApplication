//
//  NowPlayingRefreshPresenter.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 03/07/2021.
//

import Foundation
import TheMovieDB

protocol FeedLoadingStateView: AnyObject {
    func display(_ viewModel: FeedLoadingStateViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

protocol ErrorView: AnyObject {
    func display(_ viewModel: ErrorViewModel)
}

public final class NowPlayingRefreshPresenter {
    private weak var loadingView: FeedLoadingStateView?
    private let feedView: FeedView
    private weak var errorView: ErrorView?
    
    init(loadingView: FeedLoadingStateView, feedView: FeedView, errorView: ErrorView) {
        self.loadingView = loadingView
        self.feedView = feedView
        self.errorView = errorView
    }

    func didStartLoadingFeed() {
        loadingView?.display(.init(isLoading: true))
    }
    
    func didFinishLoadingFeedSuccessfully(_ feed: NowPlayingFeed) {
        loadingView?.display(.init(isLoading: false))
        feedView.display(.init(feed: feed))
    }
    
    func didFinishLoadingFeedWithError(_ error: Error) {
        loadingView?.display(.init(isLoading: false))
        errorView?.display(.init(description: error.localizedDescription))
    }
}
