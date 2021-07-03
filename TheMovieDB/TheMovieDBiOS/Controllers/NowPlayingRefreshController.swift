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
    
    init(viewModel: NowPlayingRefreshViewModel) {
        self.viewModel = viewModel
    }
    
    lazy var view = binded()
        
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func binded() -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        viewModel.onRefreshStateChange = {[weak self] isLoading in
            isLoading ? self?.view.beginRefreshing() : self?.view.endRefreshing()
        }

        return refreshControl
    }
    
}
