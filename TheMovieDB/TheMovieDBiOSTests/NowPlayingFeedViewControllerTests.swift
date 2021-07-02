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
        loader?.load(query: .init(page: 1)) { _ in }
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
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: NowPlayingFeedViewController, loader: NowPlayingLoaderSpy) {
        let loader = NowPlayingLoaderSpy()
        let sut = NowPlayingFeedViewController(loader: loader)
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
    
    
    private class NowPlayingLoaderSpy: NowPlayingLoader {
        enum Request: Equatable {
            case load(page: Int)
        }
        var requests = [Request]()
        
        func load(query: NowPlayingQuery, completion: @escaping (NowPlayingLoader.Result) -> Void) {
            requests.append(.load(page: query.page))
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
