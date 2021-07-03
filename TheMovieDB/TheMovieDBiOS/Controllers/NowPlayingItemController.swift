//
//  NowPlayingItemController.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 02/07/2021.
//

import UIKit
import TheMovieDB

public final class NowPlayingItemViewModel<Image> {
    typealias ImageDataTransformer = (Data) -> Image?
    private var task: MovieImageDataTask?
    private let model: NowPlayingCard
    private let imageLoader: MovieImageDataLoader
    private let transformer: ImageDataTransformer

    init(model: NowPlayingCard, imageLoader: MovieImageDataLoader, transformer: @escaping ImageDataTransformer) {
        self.imageLoader = imageLoader
        self.model = model
        self.transformer = transformer
    }
    
    var onLoadingImageDataStateChange: ((Bool) -> Void)?
    var onLoadImageData: ((Image?) -> Void)?
    
    func load() {
        onLoadingImageDataStateChange?(true)
        onLoadImageData?(nil)
        task = imageLoader.load(from: makeURL()) {[weak self] result in
            guard let self = self, let data = try? result.get() else {return}
            let transformed = self.transformer(data)
            self.onLoadingImageDataStateChange?(transformed == nil)
            self.onLoadImageData?(transformed)
        }
    }
    
    func preload() {
        task = imageLoader.load(from: makeURL()) { _ in }
    }
    
    private func makeURL() -> URL {
        let path = model.imagePath
        return URL(string: "https://image.tmdb.org/t/p/w500/\(path)")!
    }

    func cancelTask() {
        task?.cancel()
        task = nil
    }
}

public final class NowPlayingItemController {
    private let viewModel: NowPlayingItemViewModel<UIImage>
    private var cell: NowPlayingCardFeedCell!
    
    init(model: NowPlayingCard, imageLoader: MovieImageDataLoader) {
        self.viewModel = NowPlayingItemViewModel(model: model, imageLoader: imageLoader, transformer: UIImage.init)
    }
    
    public func view(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return binded(collectionView: collectionView, cellForItemAt: indexPath)
    }
    
    private func binded(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> NowPlayingCardFeedCell {
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NowPlayingCardFeedCell", for: indexPath) as? NowPlayingCardFeedCell
        
        viewModel.onLoadingImageDataStateChange = {[weak self] isLoading in
            guard let cell = self?.cell else { return}
            cell.isShimmering = isLoading
        }
        
        viewModel.onLoadImageData = {[weak self] loadedImage in
            guard let cell = self?.cell else { return}
            cell.imageView.image = loadedImage
        }
        
        viewModel.load()
        
        return cell
    }
    
    func preload() {
        viewModel.preload()
    }
    
    func cancelLoadImageData() {
        viewModel.cancelTask()
        releaseCellForReuse()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}
