//
//  NowPlayingItemPresenter.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 03/07/2021.
//

import Foundation

protocol ImageDataLoadingStateView {
    func display(_ viewModel: ImageDataLoadingViewModel)
}

protocol ImageDataView {
    associatedtype Image
    func display(_ viewModel: ImageDataViewModel<Image>)
}

final class NowPlayingItemPresenter<View: ImageDataView, Image> where View.Image == Image {
    typealias ImageDataTransformer = (Data) -> Image?
    private let transformer: ImageDataTransformer
    private let imageDataLoadingView: ImageDataLoadingStateView
    private let imageDataView: View

    init(imageDataLoadingView: ImageDataLoadingStateView, imageDataView: View, transformer: @escaping ImageDataTransformer) {
        self.imageDataLoadingView = imageDataLoadingView
        self.imageDataView = imageDataView
        self.transformer = transformer
    }
    
    var onLoadingImageDataStateChange: ((Bool) -> Void)?
    var onLoadImageData: ((Image?) -> Void)?
    
    func didStartLoadingImageData() {
        imageDataLoadingView.display(.init(isLoading: true))
        imageDataView.display(.init(image: nil))
    }
    
    func didFinishLoadingImageDataSuccessfuly(_ data: Data) {
        if let image = transformer(data) {
            imageDataLoadingView.display(.init(isLoading: false))
            imageDataView.display(.init(image: image))
        }
    }
}
