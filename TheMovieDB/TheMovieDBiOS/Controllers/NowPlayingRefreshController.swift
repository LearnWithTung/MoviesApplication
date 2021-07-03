//
//  NowPlayingRefreshController.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 02/07/2021.
//

import UIKit
import TheMovieDB

public final class NowPlayingRefreshViewModel {
    private let loader: NowPlayingLoader
    
    init(loader: NowPlayingLoader) {
        self.loader = loader
    }
    
    var onRefreshStateChange: ((Bool) -> Void)?
    var onLoadFeed: ((NowPlayingFeed) -> Void)?
    
    func loadFeed() {
        onRefreshStateChange?(true)
        loader.load(query: .init(page: 1)) {[weak self] result in
            self?.onRefreshStateChange?(false)
            if let feed = try? result.get() {
                self?.onLoadFeed?(feed)
            }
        }
    }

}

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
