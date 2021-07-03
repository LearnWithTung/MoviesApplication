//
//  NowPlayingItemViewModel.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 03/07/2021.
//

import Foundation
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
