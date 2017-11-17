//
//  HTTPFormPostRequestTests.swift
//  FetchTests
//
//  Created by Sebastian Skuse on 17/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

import XCTest
import Nimble
@testable import Fetch

class HTTPFormPostRequestTests: XCTestCase {

    func testItConvertsItsDictionaryBodyToData() throws {
        let testRequest = TestHTTPFormPostRequest()
        guard let data = testRequest.body else {
            return fail("Expected to receive some data")
        }
        let string = String(data: data, encoding: .utf8)! // swiftlint:disable:this
        expect(string).to(equal("test=test"))
    }
}

struct TestHTTPFormPostRequest: HTTPFormPostRequest {
    let jsonBody: [String: String] = ["test": "test"]

    let url: URL = URL(string: "https://test.com")!

    let headers: [String: String]? = nil
}
