//
//  HTTPFormPostRequestTests.swift
//  FetchTests
//
//  Created by Sebastian Skuse on 17/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

@testable import Fetch
import Nimble
import XCTest

class HTTPFormPostRequestTests: XCTestCase {

    func testItConvertsItsDictionaryBodyToData() throws {
        let testRequest = TestHTTPFormPostRequest()
        guard let data = testRequest.body else {
            return fail("Expected to receive some data")
        }
        let string = String(data: data, encoding: .utf8)! // swiftlint:disable:this
        let values = string.split(separator: "&").reduce(into: [:]) { result, query in
            let keyValue = query.split(separator: "=").map { String($0) }
            result[keyValue[0]] = keyValue[1]
        }
        expect(values as NSDictionary).to(equal(["test": "test", "extra": "characters%26here"] as NSDictionary))
    }

    func testItDefaultsToPOST() {
        let testRequest = TestHTTPFormPostRequest()
        expect(testRequest.method).to(equal(HTTPMethod.post))
    }
}

struct TestHTTPFormPostRequest: HTTPFormPostRequest {
    let jsonBody: [String: String] = ["test": "test", "extra": "characters&here"]

    let url: URL = URL(string: "https://test.com")!

    let headers: [String: String]? = nil
}
