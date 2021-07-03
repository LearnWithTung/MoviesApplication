//
//  NowPlayingCardFeedCell+Extensions.swift
//  TheMovieDBiOSTests
//
//  Created by Tung Vu on 02/07/2021.
//

import UIKit
import TheMovieDBiOS

extension NowPlayingCardFeedCell {
    var imageLoadingIndicatorVisible: Bool {
        return isShimmering
    }
    
    var loadedImageData: Data? {
        return imageView.image?.pngData()
    }
}

