//
//  NowPlayingFeedViewController.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 02/07/2021.
//

import UIKit
import TheMovieDB

public protocol MovieImageDataTask {
    func cancel()
}

public protocol MovieImageDataLoader {
    func load(from url: URL, completion: @escaping (Swift.Result<Data, Error>) -> Void) -> MovieImageDataTask
}

public class NowPlayingCardFeedCell: UICollectionViewCell {

  public let imageView = UIImageView()
  
}


public class NowPlayingFeedViewController: UICollectionViewController, UICollectionViewDataSourcePrefetching {
    private var loader: NowPlayingLoader?
    private var imageLoader: MovieImageDataLoader?
    
    private var feed: NowPlayingFeed?
    private var tasks = [IndexPath: MovieImageDataTask]()
    
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
        collectionView.register(NowPlayingCardFeedCell.self, forCellWithReuseIdentifier: "NowPlayingCardFeedCell")
        collectionView.prefetchDataSource = self
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NowPlayingCardFeedCell", for: indexPath) as! NowPlayingCardFeedCell
        cell.imageView.isShimmering = true
        cell.imageView.image = nil
        let makeURL = URL(string: "https://image.tmdb.org/t/p/w500/\(model.imagePath)")!
        tasks[indexPath] = imageLoader?.load(from: makeURL) {[weak cell] result in
            let image = (try? result.get()).flatMap(UIImage.init)
            cell?.imageView.isShimmering = image == nil
            cell?.imageView.image = image
        }
        
        return cell
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let model = feed!.items[indexPath.item]
            let makeURL = URL(string: "https://image.tmdb.org/t/p/w500/\(model.imagePath)")!
            tasks[indexPath] = imageLoader?.load(from: makeURL) {_ in}
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            tasks[indexPath]?.cancel()
            tasks[indexPath] = nil
        }
    }
}
