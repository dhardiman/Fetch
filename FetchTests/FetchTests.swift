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

let testString = "{ \"name\": \"test name\", \"desc\": \"test desc\" }"
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
            return OHHTTPStubsResponse(data: testString.dataUsingEncoding(NSUTF8StringEncoding)!, statusCode: statusCode, headers: nil)
        }
    }

    typealias TestBlock = Result<TestResponse>? -> Void

    func performGetRequestTest(request: Request = basicRequest, statusCode: Int32 = 200, passingTest requestTest: OHHTTPStubsTestBlock?, testBlock testToPerform: TestBlock) {
        if let requestTest = requestTest {
            stubRequest(statusCode: statusCode, passingTest: requestTest)
        }
        let expectation = expectationWithDescription("get request")
        var receivedResult: Result<TestResponse>?
        Fetch.get(request) { (result: Result<TestResponse>) in
            receivedResult = result
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
        testToPerform(receivedResult)
    }
    
    func testItIsPossibleToMakeAGetRequest() {
        performGetRequestTest(passingTest: { (request) -> Bool in
            return request.URL! == testURL && request.HTTPMethod == "GET"
            }) { receivedResult in
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

    func testSessionErrorsAreReturned() {
        let testError = NSError(domain: "me.davidhardiman", code: 1234, userInfo: nil)
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            return request.URL! == testURL && request.HTTPMethod == "GET"
            }) { (request) -> OHHTTPStubsResponse in
                return OHHTTPStubsResponse(error: testError)
        }
        performGetRequestTest(passingTest: nil) { receivedResult in
            switch receivedResult! {
            case .Failure(let receivedError as NSError):
                expect(receivedError).to(equal(testError))
            default:
                fail("Should be an error response")
            }
        }
    }

    func testStatusCodesAreReportedToAllowParseFailures() {
        performGetRequestTest(statusCode: 404, passingTest: { (request) -> Bool in
            return request.URL! == testURL && request.HTTPMethod == "GET"
            }) { receivedResult in
                switch receivedResult! {
                case .Failure(let receivedError as TestResponse.Fail):
                    expect(receivedError).to(equal(TestResponse.Fail.StatusFail))
                default:
                    fail("Should be an error response")
                }
        }
    }

    func testHeadersArePassedToTheRequest() {
        let testRequest = Request(url: testURL, headers: ["Test Header": "Test Value"], body: nil)
        let requestTestBlock = { (request: NSURLRequest) -> Bool in
            let urlMatch = request.URL == testURL
            let methodMatch = request.HTTPMethod == "GET"
            let headersMatch = request.allHTTPHeaderFields! == ["Test Header": "Test Value"]
            return urlMatch && methodMatch && headersMatch
        }
        performGetRequestTest(testRequest, passingTest: requestTestBlock) { (receivedResult) -> Void in
            switch receivedResult! {
            case .Success(_):
                break
            default:
                fail("Should be a successful response")
            }
        }
    }

    func testBodyIsPassedToTheRequest() {
        let testBody = "test body"
        let testRequest = Request(url: testURL, headers: nil, body: testBody.dataUsingEncoding(NSUTF8StringEncoding))

        stubRequest { (request) -> Bool in
            return request.URL! == testURL && request.HTTPMethod == "POST"
        }
        let mockSession = MockSession()
        Fetch.post(testRequest, session: mockSession) { (result: Result<TestResponse>) in
        }
        expect(mockSession.receivedBody).to(equal(testBody))
    }

}

public class MockSession: NSURLSession {
    var receivedBody: String?
    override public func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        if let body = request.HTTPBody {
            receivedBody = String(data: body, encoding: NSUTF8StringEncoding)
        }
        return NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: completionHandler)
    }
}
