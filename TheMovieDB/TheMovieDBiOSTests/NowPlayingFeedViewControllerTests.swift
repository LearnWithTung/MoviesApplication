//
//  NowPlayingFeedViewControllerTests.swift
//  TheMovieDBiOSTests
//
//  Created by Tung Vu on 02/07/2021.
//

import XCTest
import TheMovieDB

class NowPlayingFeedViewController {
    private let loader: NowPlayingLoader
    
    init(loader: NowPlayingLoader) {
        self.loader = loader
    }
}

class NowPlayingFeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotRequestLoadFeed() {
        let loader = NowPlayingLoaderSpy()
        _ = NowPlayingFeedViewController(loader: loader)
        
        
        XCTAssertEqual(loader.requestCallCount, 0)
    }
    
    // MARK: - Helpers
    private class NowPlayingLoaderSpy: NowPlayingLoader {
        var requestCallCount = 0
        
        func load(query: NowPlayingQuery, completion: @escaping (NowPlayingLoader.Result) -> Void) {
            
        }
    }
    
}
