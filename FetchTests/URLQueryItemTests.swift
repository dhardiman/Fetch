//
//  URLQueryItemTests.swift
//  FetchTests
//
//  Created by David Hardiman on 13/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

import Fetch
import Nimble
import XCTest

class URLQueryItemTests: XCTestCase {
    func testItIsPossibleToAppendQueryItemsToAURL() {
        let url = URL(string: "https://www.test.com")
        let receivedURL = url?.appending(queryItems: [URLQueryItem(name: "test", value: "test")])
        expect(receivedURL?.absoluteString).to(equal("https://www.test.com?test=test"))
    }

    func testUsingAConstructedURLAllowsQueryItemsToBeAppended() {
        let url = URL(string: "endpoint.json", relativeTo: URL(string: "https://www.test.com"))
        let receivedURL = url?.appending(queryItems: [URLQueryItem(name: "test", value: "test")])
        expect(receivedURL?.absoluteString).to(equal("https://www.test.com/endpoint.json?test=test"))
    }
}
