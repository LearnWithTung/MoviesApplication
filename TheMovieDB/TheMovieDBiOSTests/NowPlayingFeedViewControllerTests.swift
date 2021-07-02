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
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.requestCallCount, 0)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: NowPlayingFeedViewController, loader: NowPlayingLoaderSpy) {
        let loader = NowPlayingLoaderSpy()
        let sut = NowPlayingFeedViewController(loader: loader)
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
    
    
    private class NowPlayingLoaderSpy: NowPlayingLoader {
        var requestCallCount = 0
        
        func load(query: NowPlayingQuery, completion: @escaping (NowPlayingLoader.Result) -> Void) {
            
        }
    }
    
}
