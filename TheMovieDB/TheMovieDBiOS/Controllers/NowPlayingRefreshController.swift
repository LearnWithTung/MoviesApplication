//
//  NowPlayingRefreshController.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 02/07/2021.
//

import UIKit
import TheMovieDB

public final class NowPlayingRefreshController: NSObject {
    private let loader: NowPlayingLoader
    
    init(loader: NowPlayingLoader) {
        self.loader = loader
    }
    
    lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

        return refreshControl
    }()
    
    var onRefresh: ((NowPlayingFeed) -> Void)?
    
    @objc func refresh() {
        view.beginRefreshing()
        loader.load(query: .init(page: 1)) {[weak self] result in
            if Thread.isMainThread {
                self?.view.endRefreshing()
            } else {
                DispatchQueue.main.async {
                    self?.view.endRefreshing()
                }
            }
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }
        }
    }
    
}
