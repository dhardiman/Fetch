//
//  JSONRequestTests.swift
//  FetchTests
//
//  Created by David Hardiman on 12/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

@testable import Fetch
import Nimble
import XCTest

class JSONRequestTests: XCTestCase {
    func testItConvertsItsJSONBodyToData() throws {
        let testRequest = TestJSONRequest()
        guard let data = testRequest.body else {
            return fail("Expected to receive some data")
        }
        guard let receivedObject = (try JSONSerialization.jsonObject(with: data, options: [])) as? [String: String] else {
            return fail("Couldn't decode JSON")
        }
        expect(receivedObject["test"]).to(equal("test"))
    }
}

struct TestJSONRequest: JSONRequest {
    let jsonBody: Any = ["test": "test"]

    let url: URL = URL(string: "https://test.com")!

    let method = HTTPMethod.get

    let headers: [String: String]? = nil
}
