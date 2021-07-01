//
//  IntegrationEndToEndNowPlayingAPITests.swift
//  IntegrationEndToEndNowPlayingAPITests
//
//  Created by Tung Vu on 02/07/2021.
//

import XCTest
import TheMovieDB

class IntegrationEndToEndNowPlayingAPITests: XCTestCase {
    
    private let api_key = "494d9fe55bdb97bc7ee0b57dfa123t"

    func test_loadNowPlayingFeed_matchesAPIResult() {
        let url = URL(string: "https://learnwithtung.free.beeceptor.com/api/v1/movie/now_playing")!
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let remoteLoader = RemoteNowPlayingFeedLoader(url: url, credential: .init(apiKey: api_key), client: client)
        
        let exp = expectation(description: "Wait for completion")
        remoteLoader.load(query: .init(page: 1)) { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed.page, 1)
                XCTAssertEqual(feed.totalPages, 55)
                XCTAssertEqual(feed.items.count, 5)
            default:
                XCTFail("Wait for success but got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }

}
