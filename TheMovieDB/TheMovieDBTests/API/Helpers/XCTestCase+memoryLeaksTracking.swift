//
//  XCTestCase+memoryLeaksTracking.swift
//  TheMovieDBTests
//
//  Created by Tung Vu on 02/07/2021.
//

import XCTest

extension XCTestCase {
    func checkForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
