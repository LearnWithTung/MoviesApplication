//
//  NowPlayingItemController.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 02/07/2021.
//

import UIKit

public protocol NowPlayingItemDelegate {
    func didRequestLoadImageData()
    func didCancelLoadImageData()
}

public final class NowPlayingItemController {
    private let delegate: NowPlayingItemDelegate
    private var cell: NowPlayingCardFeedCell?
    
    init(delegate: NowPlayingItemDelegate) {
        self.delegate = delegate
    }
    
    public func view(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NowPlayingCardFeedCell", for: indexPath) as? NowPlayingCardFeedCell
        delegate.didRequestLoadImageData()
        return cell!
    }
    
    func preload() {
        delegate.didRequestLoadImageData()
    }
    
    func cancelLoadImageData() {
        delegate.didCancelLoadImageData()
        releaseCellForReuse()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}

extension NowPlayingItemController: ImageDataView {
    func display(_ viewModel: ImageDataViewModel<UIImage>) {
        cell?.imageView.image = viewModel.image
    }
}


extension NowPlayingItemController: ImageDataLoadingStateView {
    func display(_ viewModel: ImageDataLoadingViewModel) {
        cell?.isShimmering = viewModel.isLoading
    }
}
