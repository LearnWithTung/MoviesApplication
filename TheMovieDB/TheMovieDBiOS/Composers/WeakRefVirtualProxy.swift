//
//  WeakRefVirtualProxy.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 04/07/2021.
//

import Foundation
import UIKit

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingStateView where T: FeedLoadingStateView {
    func display(_ viewModel: FeedLoadingStateViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ErrorView where T: ErrorView {
    func display(_ viewModel: ErrorViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ImageDataLoadingStateView where T: ImageDataLoadingStateView {
    func display(_ viewModel: ImageDataLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ImageDataView where T: ImageDataView, T.Image == UIImage {
    func display(_ viewModel: ImageDataViewModel<UIImage>) {
        object?.display(viewModel)
    }
}
