//
//  NowPlayingItemController.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 02/07/2021.
//

import UIKit

public final class NowPlayingItemController {
    private let viewModel: NowPlayingItemViewModel<UIImage>
    private var cell: NowPlayingCardFeedCell!
    
    init(viewModel: NowPlayingItemViewModel<UIImage>) {
        self.viewModel = viewModel
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
