//
//  NowPlayingFeedViewController.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 02/07/2021.
//

import UIKit
import TheMovieDB

public final class NowPlayingFeedViewController: UICollectionViewController, UICollectionViewDataSourcePrefetching {
    private var refreshController: NowPlayingRefreshController?
    private var imageLoader: MovieImageDataLoader?
        
    private var cellControllers = [NowPlayingItemController]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    public convenience init(refreshController: NowPlayingRefreshController, imageLoader: MovieImageDataLoader) {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.refreshController = refreshController
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.refreshControl = refreshController?.view
        collectionView.register(NowPlayingCardFeedCell.self, forCellWithReuseIdentifier: "NowPlayingCardFeedCell")
        collectionView.prefetchDataSource = self
        refreshController?.refresh()
        
        refreshController?.onRefresh = {[weak self] feed in
            guard let self = self else {return}
            self.cellControllers = feed.items.map {NowPlayingItemController(model: $0, imageLoader: self.imageLoader!)}
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellControllers.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellController = cellControllers[indexPath.item]
        
        return cellController.view(collectionView, cellForItemAt: indexPath)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cancelImageLoad(at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let cellController = cellControllers[indexPath.item]
            cellController.preload()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelImageLoad)
    }
    
    private func cancelImageLoad(at indexPath: IndexPath) {
        let cellController = cellControllers[indexPath.item]
        cellController.cancelTask()
    }

}
