//
//  NowPlayingFeedAPIEndToEndTests.swift
//  NowPlayingFeedAPIEndToEndTests
//
//  Created by Tung Vu on 03/07/2021.
//

import XCTest
import TheMovieDB
import TheMovieDBiOSApp

class NowPlayingFeedAPIEndToEndTests: XCTestCase {

    private let api_key = "494d9fe55bdb97bc7ee0b57dfa123t"

    func test_loadNowPlayingFeed_matchesAPIResult() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")
        sut.load(query: .init(page: 1)) { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed.page, 1)
                XCTAssertEqual(feed.totalPages, 55)
                XCTAssertEqual(feed.items[0], self.card(at: 0))
                XCTAssertEqual(feed.items[1], self.card(at: 1))
                XCTAssertEqual(feed.items[2], self.card(at: 2))
                XCTAssertEqual(feed.items[3], self.card(at: 3))
                XCTAssertEqual(feed.items[4], self.card(at: 4))
            default:
                XCTFail("Wait for success but got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> RemoteNowPlayingFeedLoader {
        let url = URL(string: "https://learnwithtung.free.beeceptor.com/api/v1/movie/now_playing")!
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let decoratorClient = AuthenticatedHTTPClientDecorator(decoratee: client, credential: .init(apiKey: api_key))
        let remoteLoader = RemoteNowPlayingFeedLoader(url: url, client: decoratorClient)
        checkForMemoryLeaks(client, file: file, line: line)
        checkForMemoryLeaks(remoteLoader, file: file, line: line)
        return remoteLoader
    }
    
    private func checkForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    private func card(at index: Int = 0) -> NowPlayingCard {
        return NowPlayingCard(id: id(at: index), title: title(at: index), imagePath: posterPath(at: index))
    }
    
    private func id(at index: Int) -> Int {
        let ids = [
            508943,
            520763,
            385128,
            337404,
            637649
        ]
        
        return ids[index]
    }
    
    private func title(at index: Int) -> String {
        let titles = [
            "Luca",
            "A Quiet Place Part II",
            "F9",
            "Cruella",
            "Wrath of Man"
        ]
        return titles[index]
    }
    
    private func posterPath(at index: Int) -> String {
        let paths = [
            "/jTswp6KyDYKtvC52GbHagrZbGvD.jpg",
            "/4q2hz2m8hubgvijz8Ez0T2Os2Yv.jpg",
            "/bOFaAXmWWXC3Rbv4u4uM9ZSzRXP.jpg",
            "/rTh4K5uw9HypmpGslcKd4QfHl93.jpg",
            "/M7SUK85sKjaStg4TKhlAVyGlz3.jpg"
        ]
        
        return paths[index]
    }
}
