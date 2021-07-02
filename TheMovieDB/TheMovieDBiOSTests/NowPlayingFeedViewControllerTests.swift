//
//  NowPlayingFeedViewControllerTests.swift
//  TheMovieDBiOSTests
//
//  Created by Tung Vu on 02/07/2021.
//

import XCTest
import TheMovieDB
import TheMovieDBiOS

class NowPlayingFeedViewControllerTests: XCTestCase {
    
    func test_loadFeed_requestsLoadFirstPage() {
        let (sut, loader) = makeSUT()
        XCTAssertTrue(loader.requests.isEmpty, "Expected no feed request on initialization")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.requests, [.load(page: 1)], "Expected first feed request when view did load")
        
        sut.simulateUserRefresh()
        XCTAssertEqual(loader.requests, [.load(page: 1), .load(page: 1)], "Expected second feed request when view did load")
    }
    
    func test_viewDidLoad_displaysLoadingIndicatorOnLoad() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isLoadingIndicatorVisible, true, "Expected loading indicator visible when view did load")
        
        loader.completeWithError(anyNSError())
        XCTAssertEqual(sut.isLoadingIndicatorVisible, false, "Expected loading indicator invisible when complete load with error")
        
        sut.simulateUserRefresh()
        XCTAssertEqual(sut.isLoadingIndicatorVisible, true, "Expected loading indicator again visible when user request refresh")
        
        loader.completeSuccessWith(anyFeed())
        XCTAssertEqual(sut.isLoadingIndicatorVisible, false, "Expected loading indicator invisible when complete load success")
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: NowPlayingFeedViewController, loader: NowPlayingLoaderSpy) {
        let loader = NowPlayingLoaderSpy()
        let sut = NowPlayingFeedViewController(loader: loader)
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
    
    private func anyFeed() -> NowPlayingFeed {
        let cards = (1...5).map {uniqueNowPlayingCard(id: $0)}
        return NowPlayingFeed(items: cards, page: 1, totalPages: 1)
    }
    
    private class NowPlayingLoaderSpy: NowPlayingLoader {
        enum Request: Equatable {
            case load(page: Int)
        }
        private var messages = [(request: Request, completion: (NowPlayingLoader.Result) -> Void)]()
        
        var requests: [Request] {
            return messages.map {$0.request}
        }
        
        func load(query: NowPlayingQuery, completion: @escaping (NowPlayingLoader.Result) -> Void) {
            messages.append((.load(page: query.page), completion))
        }
        
        func completeWithError(_ error: NSError, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func completeSuccessWith(_ feed: NowPlayingFeed, at index: Int = 0) {
            messages[index].completion(.success(feed))
        }
    }
    
}

private extension NowPlayingFeedViewController {
    func simulateUserRefresh() {
        collectionView.refreshControl?.simulateRefresh()
    }
    
    var isLoadingIndicatorVisible: Bool {
        return collectionView.refreshControl?.isRefreshing == true
    }
}

private extension UIRefreshControl {
    func simulateRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
