//
//  NowPlayingFeedViewController.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 02/07/2021.
//

import UIKit
import TheMovieDB

public class NowPlayingFeedViewController: UICollectionViewController {
    private var loader: NowPlayingLoader?
    private var feed: NowPlayingFeed?
    
    public convenience init(loader: NowPlayingLoader) {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        load()
    }
    
    @objc private func load() {
        collectionView.refreshControl?.beginRefreshing()
        loader?.load(query: .init(page: 1)) {[weak self] result in
            if let feed = try? result.get() {
                self?.feed = feed
            }
            self?.collectionView.reloadData()
            self?.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feed?.items.count ?? 0
    }
}
