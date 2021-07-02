//
//  NowPlayingFeedViewController+Extensions.swift
//  TheMovieDBiOSTests
//
//  Created by Tung Vu on 02/07/2021.
//

import UIKit
import TheMovieDBiOS

extension NowPlayingFeedViewController {
    func simulateUserRefresh() {
        collectionView.refreshControl?.simulateRefresh()
    }
    
    var isLoadingIndicatorVisible: Bool {
        return collectionView.refreshControl?.isRefreshing == true
    }
    
    func numberOfItemsRendered(in section: Int = 0) -> Int {
        collectionView.numberOfSections > section ? collectionView.numberOfItems(inSection: section) : 0
    }
    
    @discardableResult
    func simulateItemVisible(at item: Int = 0) -> NowPlayingCardFeedCell? {
        guard numberOfItemsRendered(in: 0) > item else {
            return nil
        }
        let ds = collectionView.dataSource
        let indexPath = IndexPath(item: item, section: 0)
        return ds?.collectionView(collectionView, cellForItemAt: indexPath) as? NowPlayingCardFeedCell
    }
    
    @discardableResult
    func simulateItemNotVisible(at item: Int = 0) -> NowPlayingCardFeedCell? {
        let cell = simulateItemVisible(at: item)
        let dl = collectionView.delegate
        let indexPath = IndexPath(item: item, section: 0)
        dl?.collectionView?(collectionView, didEndDisplaying: cell!, forItemAt: indexPath)
        return cell
    }
    
    func simulateItemNearVisible(at item: Int = 0) {
        let pf = collectionView.prefetchDataSource
        let indexPath = IndexPath(item: item, section: 0)
        pf?.collectionView(collectionView, prefetchItemsAt: [indexPath])
    }
    
    func simulateItemNotNearVisible(at item: Int = 0) {
        simulateItemNearVisible(at: item)
        let pf = collectionView.prefetchDataSource
        let indexPath = IndexPath(item: item, section: 0)
        pf?.collectionView?(collectionView, cancelPrefetchingForItemsAt: [indexPath])
    }
}
