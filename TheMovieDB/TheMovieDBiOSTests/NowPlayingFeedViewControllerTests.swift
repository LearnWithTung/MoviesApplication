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
    
    func test_loadCompletion_rendersCellOnCompleteLoadSuccessfully() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        let emptyFeed = makeFeedFrom(cards: [])
        loader.completeSuccessWith(emptyFeed)
        assertThat(sut, isRendering: emptyFeed)
        
        sut.simulateUserRefresh()
        let oneCardFeed = makeFeedFrom(cards: [uniqueNowPlayingCard()])
        loader.completeSuccessWith(oneCardFeed)
        assertThat(sut, isRendering: oneCardFeed)

        
        sut.simulateUserRefresh()
        let feed = anyFeed()
        loader.completeSuccessWith(feed)
        assertThat(sut, isRendering: feed)
    }
    
    func test_loadCompletion_doesNotAlterCurrentStateOnLoadFails() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        let feed = anyFeed()
        loader.completeSuccessWith(feed)
        
        sut.simulateUserRefresh()
        loader.completeWithError(anyNSError())
        
        assertThat(sut, isRendering: feed)
    }
    
    func test_loadImage_requestsLoadImageOnCellIsVisible() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeSuccessWith(makeFeedFrom(cards: []))
        XCTAssertTrue(loader.imageLoadedURLs.isEmpty)
        
        sut.simulateUserRefresh()
        let card0 = uniqueNowPlayingCard(id: 0)
        let card1 = uniqueNowPlayingCard(id: 1)
        let feed = NowPlayingFeed(items: [card0, card1], page: 1, totalPages: 1)
        loader.completeSuccessWith(feed)
        
        let imageURL0 = makeURL(from: card0.imagePath)
        sut.simulateItemVisible(at: 0)
        XCTAssertEqual(loader.imageLoadedURLs, [imageURL0])
        
        let imageURL1 = makeURL(from: card1.imagePath)
        sut.simulateItemVisible(at: 1)
        XCTAssertEqual(loader.imageLoadedURLs, [imageURL0, imageURL1])
    }
    
    func test_loadImage_cancelsLoadImageOnCellIsNotVisible() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let card0 = uniqueNowPlayingCard(id: 0)
        let card1 = uniqueNowPlayingCard(id: 1)
        let feed = NowPlayingFeed(items: [card0, card1], page: 1, totalPages: 1)
        loader.completeSuccessWith(feed)
        
        let imageURL0 = makeURL(from: card0.imagePath)
        sut.simulateItemNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledURLs, [imageURL0])
        
        let imageURL1 = makeURL(from: card1.imagePath)
        sut.simulateItemNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledURLs, [imageURL0, imageURL1])
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: NowPlayingFeedViewController, loader: NowPlayingLoaderSpy) {
        let loader = NowPlayingLoaderSpy()
        let sut = NowPlayingFeedViewController(loader: loader, imageLoader: loader)
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: NowPlayingFeedViewController, isRendering feed: NowPlayingFeed, file: StaticString = #filePath, line: UInt = #line) {
        guard feed.items.count == sut.numberOfItemsRendered() else {
            return XCTFail("Expected renders \(feed.items.count) but got \(sut.numberOfItemsRendered()) instead", file: file, line: line)
        }
    }
    
    private func makeURL(from path: String, file: StaticString = #file, line: UInt = #line) -> URL {
        let urlString = "https://image.tmdb.org/t/p/w500/\(path)"
        guard let url = URL(string: urlString) else {
          preconditionFailure("Could not create URL for \(urlString)", file: file, line: line)
        }
        return url
    }
    
    private func makeFeedFrom(cards: [NowPlayingCard], page: Int = 1, totalPages: Int = 1) -> NowPlayingFeed {
        return NowPlayingFeed(items: cards, page: page, totalPages: totalPages)
    }
    
    private func anyFeed() -> NowPlayingFeed {
        let cards = (1...5).map {uniqueNowPlayingCard(id: $0)}
        return makeFeedFrom(cards: cards)
    }
    
    private class NowPlayingLoaderSpy: NowPlayingLoader, MovieImageDataLoader {
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
        
        // MARK: - Image Loader
        
        var imageLoadedURLs = [URL]()
        var cancelledURLs = [URL]()
        
        private struct Task: MovieImageDataTask {
            let action: () -> Void
            
            init(action: @escaping () -> Void) {
                self.action = action
            }
            
            func cancel() {
                action()
            }
        }
        
        func load(from url: URL) -> MovieImageDataTask {
            imageLoadedURLs.append(url)
            return Task {[weak self] in self?.cancelLoadImage(url)}
        }
        
        private func cancelLoadImage(_ url: URL) {
            cancelledURLs.append(url)
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
    
    func numberOfItemsRendered(in section: Int = 0) -> Int {
        collectionView.numberOfSections > section ? collectionView.numberOfItems(inSection: section) : 0
    }
    
    @discardableResult
    func simulateItemVisible(at item: Int = 0) -> UICollectionViewCell? {
        guard numberOfItemsRendered(in: 0) > item else {
            return nil
        }
        let ds = collectionView.dataSource
        let indexPath = IndexPath(item: item, section: 0)
        return ds?.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    func simulateItemNotVisible(at item: Int = 0) {
        let cell = simulateItemVisible(at: item)
        let dl = collectionView.delegate
        let indexPath = IndexPath(item: item, section: 0)
        dl?.collectionView?(collectionView, didEndDisplaying: cell!, forItemAt: indexPath)
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
