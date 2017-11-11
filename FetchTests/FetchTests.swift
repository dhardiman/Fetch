//
//  FetchTests.swift
//  FetchTests
//
//  Created by David Hardiman on 13/02/2016.
//  Copyright © 2016 David Hardiman. All rights reserved.
//

import XCTest
import Nimble
import OHHTTPStubs
@testable import Fetch

let testString = "{ \"name\": \"test name\", \"desc\": \"test desc\" }"
let testURL = URL(string: "https://fetch.davidhardiman.me")!
let basicRequest = Request(url: testURL)

struct TestResponse: Parsable {
    enum Fail: Error {
        case statusFail
        case parseFail
    }

    let name: String
    let desc: String
    let headers: [String: String]?

    static func parse(fromData data: Data?, withStatus status: Int, headers: [String: String]?) -> Result<TestResponse> {
        if status != 200 {
            return .failure(Fail.statusFail)
        }
        do {
            if let data = data, let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                return .success(TestResponse(name: dict["name"]!, desc: dict["desc"]!, headers: headers))
            }
        } catch {}
        return .failure(Fail.parseFail)
    }
}

class FetchTests: XCTestCase {

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func stubRequest(statusCode: Int32 = 200, passingTest test: @escaping OHHTTPStubsTestBlock) {
        OHHTTPStubs.stubRequests(passingTest: test) { (_) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: testString.data(using: String.Encoding.utf8)!, statusCode: statusCode, headers: ["header": "test header"])
        }
    }

    typealias TestBlock = (Result<TestResponse>?) -> Void

    func performGetRequestTest(request: Request = basicRequest, statusCode: Int32 = 200, passingTest requestTest: OHHTTPStubsTestBlock?, testBlock testToPerform: TestBlock) {
        if let requestTest = requestTest {
            stubRequest(statusCode: statusCode, passingTest: requestTest)
        }
        let exp = expectation(description: "get request")
        var receivedResult: Result<TestResponse>?
        Fetch.get(request) { (result: Result<TestResponse>) in
            receivedResult = result
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        testToPerform(receivedResult)
    }

    func testItIsPossibleToMakeAGetRequest() {
        performGetRequestTest(passingTest: { (request) -> Bool in
            request.url! == testURL && request.httpMethod == "GET"
        }, testBlock: { receivedResult in
            guard let testResult = receivedResult else {
                fail("Should have received a result")
                return
            }
            switch testResult {
            case .success(let response):
                expect(response.name).to(equal("test name"))
                expect(response.desc).to(equal("test desc"))
                expect(response.headers).to(equal(["header": "test header", "Content-Length": "44"]))
            default:
                fail("Should be a successful response")
            }
        })
    }

    func testItIsPossibleToMakeAPostRequest() {
        stubRequest { (request) -> Bool in
            return request.url! == testURL && request.httpMethod == "POST"
        }
        let exp = expectation(description: "post request")
        var receivedResult: Result<TestResponse>?
        Fetch.post(basicRequest) { (result: Result<TestResponse>) in
            receivedResult = result
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        switch receivedResult! {
        case .success:
            break
        default:
            fail("Should be a successful response")
        }
    }

    func testSessionErrorsAreReturned() {
        let testError = NSError(domain: "me.davidhardiman", code: 1234, userInfo: nil)
        OHHTTPStubs.stubRequests(passingTest: { (request) -> Bool in
            return request.url! == testURL && request.httpMethod == "GET"
        }, withStubResponse: { (_) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(error: testError)
        })
        performGetRequestTest(passingTest: nil) { receivedResult in
            switch receivedResult! {
            case .failure(let receivedError as NSError):
                expect(receivedError).to(equal(testError))
            default:
                fail("Should be an error response")
            }
        }
    }

    func testStatusCodesAreReportedToAllowParseFailures() {
        performGetRequestTest(statusCode: 404, passingTest: { (request) -> Bool in
            return request.url! == testURL && request.httpMethod == "GET"
        }, testBlock: { receivedResult in
            switch receivedResult! {
            case .failure(let receivedError as TestResponse.Fail):
                expect(receivedError).to(equal(TestResponse.Fail.statusFail))
            default:
                fail("Should be an error response")
            }
        })
    }

    func testHeadersArePassedToTheRequest() {
        let testRequest = Request(url: testURL, headers: ["Test Header": "Test Value"], body: nil)
        let requestTestBlock = { (request: URLRequest) -> Bool in
            let urlMatch = request.url == testURL
            let methodMatch = request.httpMethod == "GET"
            let headersMatch = request.allHTTPHeaderFields! == ["Test Header": "Test Value"]
            return urlMatch && methodMatch && headersMatch
        }
        performGetRequestTest(request: testRequest, passingTest: requestTestBlock) { (receivedResult) -> Void in
            switch receivedResult! {
            case .success:
                break
            default:
                fail("Should be a successful response")
            }
        }
    }

    func testBodyIsPassedToTheRequest() {
        let testBody = "test body"
        let testRequest = Request(url: testURL, headers: nil, body: testBody.data(using: String.Encoding.utf8))

        stubRequest { (request) -> Bool in
            return request.url! == testURL && request.httpMethod == "POST"
        }
        let mockSession = MockSession()
        Fetch.post(testRequest, session: mockSession) { (_: Result<TestResponse>) in
        }
        expect(mockSession.receivedBody).to(equal(testBody))
    }

    func testCallbackQueueCanBeSpecified() {
        let callBackQueue = OperationQueue()
        stubRequest { (request) -> Bool in
            return request.url! == testURL && request.httpMethod == "POST"
        }
        let exp = expectation(description: "post request")
        var receivedQueue: OperationQueue?
        Fetch.post(basicRequest, responseQueue: callBackQueue) { (_: Result<TestResponse>) in
            receivedQueue = OperationQueue.current
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        expect(receivedQueue).to(equal(callBackQueue))
    }

}

public class MockSession: URLSession {
    var receivedBody: String?
    public override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        if let body = request.httpBody {
            receivedBody = String(data: body, encoding: String.Encoding.utf8)
        }
        return URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
    }
}
