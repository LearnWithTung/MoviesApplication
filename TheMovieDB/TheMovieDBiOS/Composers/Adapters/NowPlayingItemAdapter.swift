//
//  NowPlayingItemAdapter.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 04/07/2021.
//

import Foundation
import TheMovieDB

final class NowPlayingItemAdapter<View: ImageDataView, Image>: NowPlayingItemDelegate where View.Image == Image {
    private let imageLoader: MovieImageDataLoader
    var presenter: NowPlayingItemPresenter<View, Image>?
    private let model: NowPlayingCard
    private var task: MovieImageDataTask?
    
    init(imageLoader: MovieImageDataLoader, model: NowPlayingCard){
        self.imageLoader = imageLoader
        self.model = model
    }
    
    func didRequestLoadImageData() {
        presenter?.didStartLoadingImageData()
        task = imageLoader.load(from: makeURL()) { [weak self] result in
            guard let self = self, let data = try? result.get() else {return}
            self.presenter?.didFinishLoadingImageDataSuccessfuly(data)
        }
    }
    
    func didCancelLoadImageData() {
        cancelTask()
    }
    
    private func cancelTask() {
        task?.cancel()
        task = nil
    }
    
    private func makeURL() -> URL {
        let path = model.imagePath
        return URL(string: "https://image.tmdb.org/t/p/w500/\(path)")!
    }
}
