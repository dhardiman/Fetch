//
//  FetchTests.swift
//  FetchTests
//
//  Created by David Hardiman on 13/02/2016.
//  Copyright © 2016 David Hardiman. All rights reserved.
//

@testable import Fetch
import Nimble
import OHHTTPStubs
import XCTest

let testString = "{ \"name\": \"test name\", \"desc\": \"test desc\" }"
let testURL = URL(string: "https://fetch.davidhardiman.me")!

let basicRequest = BasicURLRequest(url: testURL)

struct TestResponse: Parsable {
    enum Fail: Error {
        case statusFail
        case parseFail
    }

    let name: String
    let desc: String
    let response: Response

    static func parse(response: Response, errorParser: ErrorParsing.Type?) -> FetchResult<TestResponse> {
        if response.status != 200 {
            return .failure(Fail.statusFail)
        }
        do {
            if let data = response.data, let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                return .success(TestResponse(name: dict["name"]!, desc: dict["desc"]!, response: response))
            }
        } catch {}
        return .failure(Fail.parseFail)
    }
}

enum CustomError: ErrorParsing, Error {
    static func parseError(from data: Data?, statusCode: Int) -> Error? {
        return CustomError.error
    }

    case error
}

class FetchTests: XCTestCase {

    var session: Session!

    override func setUp() {
        super.setUp()
        session = Session()
    }

    override func tearDown() {
        session = nil
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func stubRequest(statusCode: Int32 = 200, passingTest test: @escaping OHHTTPStubsTestBlock) {
        OHHTTPStubs.stubRequests(passingTest: test) { (_) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: testString.data(using: String.Encoding.utf8)!, statusCode: statusCode, headers: ["header": "test header"])
        }
    }

    typealias TestBlock = (FetchResult<TestResponse>?) -> Void

    func performGetRequestTest(request: Request = basicRequest, statusCode: Int32 = 200, passingTest requestTest: OHHTTPStubsTestBlock?, testBlock testToPerform: TestBlock) {
        if let requestTest = requestTest {
            stubRequest(statusCode: statusCode, passingTest: requestTest)
        }
        let exp = expectation(description: "get request")
        var receivedResult: FetchResult<TestResponse>?
        session.perform(request) { (result: FetchResult<TestResponse>) in
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
                expect(response.response.headers).to(equal(["header": "test header", "Content-Length": "44"]))
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
        var receivedResult: FetchResult<TestResponse>?
        session.perform(BasicURLRequest(url: testURL, method: .post)) { (result: FetchResult<TestResponse>) in
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

    func testUserInfoIsPassedFromTheRequestToTheResponse() {
        let request = BasicURLRequest(url: testURL, userInfo: ["Test": "Test Value!"])

        let requestTestBlock = { (request: URLRequest) -> Bool in
            let urlMatch = request.url == testURL
            let methodMatch = request.httpMethod == "GET"
            return urlMatch && methodMatch
        }
        performGetRequestTest(request: request, passingTest: requestTestBlock) { (receivedResult) -> Void in
            switch receivedResult! {
            case .success(let response):
                expect(response.response.userInfo?["Test"] as? String).to(equal("Test Value!"))
            default:
                fail("Should be a successful response")
            }
        }
    }

    func testHeadersArePassedToTheRequest() {
        let testRequest = BasicURLRequest(url: testURL, headers: ["Test Header": "Test Value"], body: nil)
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
        let testRequest = BasicURLRequest(url: testURL, method: .post, headers: nil, body: testBody.data(using: String.Encoding.utf8))

        stubRequest { (request) -> Bool in
            return request.url! == testURL && request.httpMethod == "POST"
        }
        let mockSession = MockSession()
        session = Session(session: mockSession)
        session.perform(testRequest) { (_: FetchResult<TestResponse>) in
        }
        expect(mockSession.receivedBody).to(equal(testBody))
    }

    func testTheHTTPMethodIsPassedToTheResponse() {
        stubRequest { (request) -> Bool in
            return request.url! == testURL && request.httpMethod == "TRACE"
        }
        let exp = expectation(description: "trace request")
        var receivedResult: FetchResult<TestResponse>?
        session.perform(BasicURLRequest(url: testURL, method: .trace)) { (result: FetchResult<TestResponse>) in
            receivedResult = result
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        switch receivedResult! {
        case .success(let response):
            expect(response.response.originalRequest.method).to(equal(.trace))
        default:
            fail("Should be a successful response")
        }
    }

    func testCallbackQueueCanBeSpecified() {
        let callBackQueue = OperationQueue()
        stubRequest { (request) -> Bool in
            return request.url! == testURL && request.httpMethod == "POST"
        }
        let exp = expectation(description: "post request")
        var receivedQueue: OperationQueue?
        session = Session(responseQueue: callBackQueue)
        session.perform(BasicURLRequest(url: testURL, method: .post)) { (_: FetchResult<TestResponse>) in
            receivedQueue = OperationQueue.current
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        expect(receivedQueue).to(equal(callBackQueue))
    }

    func testAnUnknownResponseTypeReturnsAnError() {
        let mockSession = MockSession()
        mockSession.mockResponse = URLResponse()
        session = Session(session: mockSession)
        var receivedResult: FetchResult<TestResponse>?
        let exp = expectation(description: "test request")
        session.perform(basicRequest) { (result: FetchResult<TestResponse>) in
            receivedResult = result
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        guard let result = receivedResult, case .failure(let error) = result else {
            return fail("Expected a failure")
        }
        guard let sessionError = error as? SessionError else {
            return fail("Expected a session error")
        }
        expect(sessionError).to(equal(SessionError.unknownResponseType))
    }

    func testAllTasksCanBeCancelled() {
        let mockSession = MockSession()
        session = Session(session: mockSession)
        let task1 = session.perform(BasicURLRequest(url: testURL), completion: { (_: FetchResult<TestResponse>) in }) as? MockTask
        let task2 = session.perform(BasicURLRequest(url: testURL), completion: { (_: FetchResult<TestResponse>) in }) as? MockTask
        session.cancelAllTasks()
        expect(task1?.cancelCalled).to(beTrue())
        expect(task2?.cancelCalled).to(beTrue())
    }

    func testNoDataResponseSuccess() {
        stubRequest { (request) -> Bool in
            return request.url! == testURL && request.httpMethod == "GET"
        }
        let exp = expectation(description: "get request")
        var receivedResult: VoidResult?
        session.perform(BasicURLRequest(url: testURL)) { (result: VoidResult) in
            receivedResult = result
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        switch receivedResult! {
        case .success:
            break
        case .failure:
            fail("Should be a successful response")
        }
    }

    func testNoDataResponseFailure() {
        stubRequest(statusCode: 400) { (request) -> Bool in
            return request.url! == testURL && request.httpMethod == "GET"
        }
        let exp = expectation(description: "get request")
        var receivedResult: VoidResult?
        session.perform(BasicURLRequest(url: testURL)) { (result: VoidResult) in
            receivedResult = result
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        switch receivedResult! {
        case .success:
            fail("Should be a failing response")
        case let .failure(NoDataResponseError.httpError(code)):
            expect(code).to(equal(400))
        default:
            fail("Should be a 400 response")
        }
    }

    func testNoDataResponseFailureWithCustomErrorHandler() {
        stubRequest(statusCode: 400) { (request) -> Bool in
            return request.url! == testURL && request.httpMethod == "GET"
        }
        let exp = expectation(description: "get request")
        var receivedResult: VoidResult?
        session.perform(BasicURLRequest(url: testURL), errorParser: CustomError.self) { (result: VoidResult) in
            receivedResult = result
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        switch receivedResult! {
        case .success:
            fail("Should be a failing response")
        case .failure(let error as CustomError):
            expect(error).to(equal(CustomError.error))
        default:
            fail("Expected a custom error")
        }
    }

}

public class MockSession: URLSession {
    var receivedBody: String?
    var mockResponse: URLResponse?
    public override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        if let body = request.httpBody {
            receivedBody = String(data: body, encoding: String.Encoding.utf8)
        }
        if let mockResponse = mockResponse {
            completionHandler(nil, mockResponse, nil)
        }
        let task = MockTask()
        mockedTasks.append(task)
        return task
    }

    var mockedTasks = [URLSessionTask]()
    public override func getAllTasks(completionHandler: @escaping ([URLSessionTask]) -> Void) {
        completionHandler(mockedTasks)
    }
}

public class MockTask: URLSessionDataTask {
    var cancelCalled = false
    public override func cancel() {
        cancelCalled = true
    }

    override public func resume() {}
}
