//
//  NowPlayingRefreshController.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 02/07/2021.
//

import UIKit
import TheMovieDB

public final class NowPlayingRefreshController: NSObject {
    private let viewModel: NowPlayingRefreshViewModel
    
    init(loader: NowPlayingLoader) {
        self.viewModel = NowPlayingRefreshViewModel(loader: loader)
    }
    
    lazy var view = binded()
    
    var onRefresh: ((NowPlayingFeed) -> Void)?
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func binded() -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        viewModel.onRefreshStateChange = {[weak self] isLoading in
            isLoading ? self?.view.beginRefreshing() : self?.view.endRefreshing()
        }
        
        viewModel.onLoadFeed = { [weak self] feed in
            self?.onRefresh?(feed)
        }

        return refreshControl
    }
    
}
