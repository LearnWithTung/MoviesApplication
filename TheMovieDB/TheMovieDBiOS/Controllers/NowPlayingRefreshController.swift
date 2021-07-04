//
//  NowPlayingRefreshController.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 02/07/2021.
//

import UIKit

protocol NowPlayingRefreshDelegate {
    func didRequestRefreshFeed()
}

public final class NowPlayingRefreshController: NSObject, FeedLoadingStateView {
    private let delegate: NowPlayingRefreshDelegate
    
    init(delegate: NowPlayingRefreshDelegate) {
        self.delegate = delegate
    }
    
    lazy var view = loadView()
        
    @objc func refresh() {
        delegate.didRequestRefreshFeed()
    }
    
    private func loadView() -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return refreshControl
    }
    
    func display(_ viewModel: FeedLoadingStateViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
}
