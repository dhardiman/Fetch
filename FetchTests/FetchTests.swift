//
//  FetchTests.swift
//  FetchTests
//
//  Created by David Hardiman on 13/02/2016.
//  Copyright © 2016 David Hardiman. All rights reserved.
//

import XCTest
import Nimble
import MIQTestingFramework
@testable import Fetch

let testString: NSString = "{ \"name\": \"test name\", \"desc\": \"test desc\" }"
let testURL = NSURL(string: "https://fetch.davidhardiman.me")!
let basicRequest = Request(url: testURL)

struct TestResponse: Parsable {
    enum Fail: ErrorType {
        case StatusFail
        case ParseFail
    }

    let name: String
    let desc: String

    static func parse(fromData data: NSData, withStatus status: Int) -> Result<TestResponse> {
        if status != 200 {
            return .Failure(Fail.StatusFail)
        }
        do {
            if let dict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: String] {
                return .Success(TestResponse(name: dict["name"]!, desc: dict["desc"]!))
            }
        } catch {}
        return .Failure(Fail.ParseFail)

    }
}

class FetchTests: XCTestCase {

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func stubRequest(statusCode statusCode: Int32 = 200, passingTest test: OHHTTPStubsTestBlock) {
        OHHTTPStubs.stubRequestsPassingTest(test) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: testString.dataUsingEncoding(NSUTF8StringEncoding)!, statusCode: 200, headers: nil)
        }
    }
    
    func testItIsPossibleToMakeAGetRequest() {
        stubRequest { (request) -> Bool in
            return request.URL! == testURL && request.HTTPMethod == "GET"
        }

        let expectation = expectationWithDescription("get request")
        var receivedResult: Result<TestResponse>?
        Fetch.get(basicRequest) { (result: Result<TestResponse>) in
            receivedResult = result
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
        guard let testResult = receivedResult else {
            fail("Should have received a result")
            return
        }
        switch testResult {
        case .Success(let response):
            expect(response.name).to(equal("test name"))
            expect(response.desc).to(equal("test desc"))
        default:
            fail("Should be a successful response")
        }
    }

    func testItIsPossibleToMakeAPostRequest() {
        stubRequest { (request) -> Bool in
            return request.URL! == testURL && request.HTTPMethod == "POST"
        }
        let expectation = expectationWithDescription("post request")
        var receivedResult: Result<TestResponse>?
        Fetch.post(basicRequest) { (result: Result<TestResponse>) in
            receivedResult = result
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
        switch receivedResult! {
        case .Success(_):
            break
        default:
            fail("Should be a successful response")
        }
    }


}
