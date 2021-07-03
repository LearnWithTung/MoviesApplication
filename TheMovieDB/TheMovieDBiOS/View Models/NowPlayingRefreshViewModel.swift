//
//  NowPlayingRefreshViewModel.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 03/07/2021.
//

import Foundation
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
