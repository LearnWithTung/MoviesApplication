//
//  NowPlayingFeedViewController.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 02/07/2021.
//

import UIKit
import TheMovieDB

public protocol MovieImageDataLoader {
    func load(from url: URL)
}

public class NowPlayingFeedViewController: UICollectionViewController {
    private var loader: NowPlayingLoader?
    private var imageLoader: MovieImageDataLoader?
    
    private var feed: NowPlayingFeed?
    
    public convenience init(loader: NowPlayingLoader, imageLoader: MovieImageDataLoader) {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.loader = loader
        self.imageLoader = imageLoader
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
        return feed!.items.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = feed!.items[indexPath.item]
        let cell = UICollectionViewCell()
        
        let makeURL = URL(string: "https://image.tmdb.org/t/p/w500/\(model.imagePath)")!
        imageLoader?.load(from: makeURL)
        
        return cell
    }
}
