//
//  NowPlayingFeedViewControllerTests.swift
//  TheMovieDBiOSTests
//
//  Created by Tung Vu on 02/07/2021.
//

import XCTest
import TheMovieDB

class NowPlayingFeedViewController: UICollectionViewController {
    private var loader: NowPlayingLoader?
    
    convenience init(loader: NowPlayingLoader) {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        refreshControl.beginRefreshing()
        
        load()
    }
    
    @objc private func load() {
        loader?.load(query: .init(page: 1)) {[weak self] _ in
            self?.collectionView.refreshControl?.endRefreshing()
        }
    }
}

class NowPlayingFeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotRequestLoadFeed() {
        let (_, loader) = makeSUT()
        
        XCTAssertTrue(loader.requests.isEmpty)
    }
    
    func test_viewDidLoad_requestsLoadFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.requests, [.load(page: 1)])
    }
    
    func test_userRefresh_requestsLoadFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        sut.simulateUserRefresh()

        XCTAssertEqual(loader.requests, [.load(page: 1), .load(page: 1)])
    }
    
    func test_viewDidLoad_displaysLoadingIndicatorOnLoad() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.isLoadingIndicatorVisible, true)
    }
    
    func test_viewDidLoad_hidesLoadingIndicatorOnCompleteLoad() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeWithError(anyNSError())

        XCTAssertEqual(sut.isLoadingIndicatorVisible, false)
    }
    
    func test_userRefresh_displaysLoadingIndicatorOnLoad() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.simulateUserRefresh()

        XCTAssertEqual(sut.isLoadingIndicatorVisible, true)
    }
    
    func test_userRefresh_hidesLoadingIndicatorOnCompleteLoad() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let cards = (1...5).map {uniqueNowPlayingCard(id: $0)}
        let feed = NowPlayingFeed(items: cards, page: 1, totalPages: 1)
        loader.completeSuccessWith(feed)

        XCTAssertEqual(sut.isLoadingIndicatorVisible, false)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: NowPlayingFeedViewController, loader: NowPlayingLoaderSpy) {
        let loader = NowPlayingLoaderSpy()
        let sut = NowPlayingFeedViewController(loader: loader)
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
    
    private func uniqueNowPlayingCard(id: Int = 0) -> NowPlayingCard {
        return NowPlayingCard(id: id, title: "\(UUID().uuidString) title", imagePath: "/\(UUID().uuidString)_image_path")
    }
        
    private func anyNSError() -> NSError {
        NSError(domain: "any", code: 0, userInfo: nil)
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
