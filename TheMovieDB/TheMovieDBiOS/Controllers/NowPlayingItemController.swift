//
//  NowPlayingItemController.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 02/07/2021.
//

import UIKit
import TheMovieDB

public final class NowPlayingItemController {
    private let model: NowPlayingCard
    private let imageLoader: MovieImageDataLoader
    private var task: MovieImageDataTask?
    
    init(model: NowPlayingCard, imageLoader: MovieImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    public func view(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NowPlayingCardFeedCell", for: indexPath) as! NowPlayingCardFeedCell
        cell.imageView.isShimmering = true
        cell.imageView.image = nil
        task = imageLoader.load(from: makeURL(from: model.imagePath)) {[weak self, weak cell] result in
            guard self?.task != nil else {
                cell = nil
                return
            }
            let image = (try? result.get()).flatMap(UIImage.init)
            if Thread.isMainThread {
                cell?.imageView.isShimmering = image == nil
                cell?.imageView.image = image
            } else {
                DispatchQueue.main.async {
                    cell?.imageView.isShimmering = image == nil
                    cell?.imageView.image = image
                }
            }
        }
        
        return cell
    }
    
    private func makeURL(from path: String) -> URL {
        return URL(string: "https://image.tmdb.org/t/p/w500/\(path)")!
    }
    
    func preload() {
        task = imageLoader.load(from: makeURL(from: model.imagePath)) { _ in }
    }
    
    func cancelTask() {
        task?.cancel()
        task = nil
    }
}
