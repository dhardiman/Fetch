//
//  FetchCombineTests.swift
//  Fetch-iOS
//
//  Created by David Hardiman on 21/06/2019.
//  Copyright © 2019 David Hardiman. All rights reserved.
//

#if canImport(Combine)
    import Combine
    @testable import Fetch
    import Nimble
    import OHHTTPStubs
    import XCTest

    extension FetchTests {
        func testItIsPossibleToMakeAGetRequestUsingAPublisher() {
            guard #available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *, *) else {
                // @available attribute doesn't seem to work for tests.
                // I assume XCTest can't read the attribute, which would make sense.
                return
            }
            stubRequest(passingTest: { $0.url! == testURL && $0.httpMethod == "GET" })
            let publisher = session!.publisher(for: basicRequest, errorParser: nil) as AnyPublisher<TestResponse, Error>
            let exp = expectation(description: "get request")
            let sub = publisher.sink(receiveCompletion: { _ in }, receiveValue: {
                expect($0.name).to(equal("test name"))
                expect($0.desc).to(equal("test desc"))
                exp.fulfill()
            })
            waitForExpectations(timeout: 10.0, handler: nil)
            print("\(sub.hashValue)") // Need to keep a reference to avoid the subscriber being disposed immediately, this is to silence the warning
        }

        func testSessionErrorsAreReturnedUsingAPublisher() {
            guard #available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *, *) else { return }
            let testError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil)
            HTTPStubs.stubRequests(passingTest: { (request) -> Bool in
                return request.url! == testURL && request.httpMethod == "GET"
            }, withStubResponse: { (_) -> HTTPStubsResponse in
                return HTTPStubsResponse(error: testError)
            })
            let publisher = session!.publisher(for: basicRequest, errorParser: nil) as AnyPublisher<TestResponse, Error>
            let exp = expectation(description: "get request")
            let sub = publisher.sink(receiveCompletion: {
                switch $0 {
                case .finished:
                    fail("Expected an error")
                case .failure(let error as NSError):
                    expect(error.code).to(equal(testError.code))
                    expect(error.domain).to(equal(testError.domain))
                }
                exp.fulfill()
            }, receiveValue: { _ in })
            waitForExpectations(timeout: 1.0, handler: nil)
            print("\(sub.hashValue)")
        }

        func testItReturnsParsedErrorsCorrectlyUsingAPublisher() {
            guard #available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *, *) else { return }
            stubRequest(statusCode: 400) { (request) -> Bool in
                return request.url! == testURL && request.httpMethod == "GET"
            }
            let exp = expectation(description: "get request")
            let publisher = session!.publisher(for: basicRequest, errorParser: CustomError.self) as AnyPublisher<NoDataResponse, Error>
            var receivedError: Error?
            let sub = publisher.sink(receiveCompletion: {
                switch $0 {
                case .finished:
                    fail("Expected an error")
                case .failure(let error):
                    receivedError = error
                }
                exp.fulfill()
            }, receiveValue: { _ in })
            waitForExpectations(timeout: 1.0, handler: nil)
            let customError = receivedError as! CustomError // swiftlint:disable:this force_cast
            expect(customError).to(equal(CustomError.error))
            print("\(sub.hashValue)")
        }

        func testItIncrementsTheActivityMonitorCorrectly() {
            guard #available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *, *) else { return }
            let stubMonitor = SessionActivityMonitor(initialValue: 0, isAsynchronous: false)
            stubRequest(passingTest: { $0.url! == testURL && $0.httpMethod == "GET" })
            var isCurrentlyActive: Bool = false
            SessionActivityMonitor.sessionActivityChanged = {
                isCurrentlyActive = $0
            }
            session.activityMonitor = stubMonitor
            let publisher = session!.publisher(for: basicRequest, errorParser: nil) as AnyPublisher<TestResponse, Error>
            expect(isCurrentlyActive).to(beTrue())
            let exp = expectation(description: "get request")
            let sub = publisher.sink(receiveCompletion: { _ in }, receiveValue: { _ in
                exp.fulfill()
            })
            waitForExpectations(timeout: 1.0, handler: nil)
            expect(isCurrentlyActive).to(beFalse())
            print("\(sub.hashValue)")
        }

        func testItDecrementsTheActivityMonitorCorrectlyOnSessionErrors() {
            guard #available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *, *) else { return }
            let stubMonitor = SessionActivityMonitor(initialValue: 0, isAsynchronous: false)
            session.activityMonitor = stubMonitor
            let testError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil)
            HTTPStubs.stubRequests(passingTest: { (request) -> Bool in
                return request.url! == testURL && request.httpMethod == "GET"
            }, withStubResponse: { (_) -> HTTPStubsResponse in
                return HTTPStubsResponse(error: testError)
            })
            var isCurrentlyActive: Bool = false
            SessionActivityMonitor.sessionActivityChanged = {
                isCurrentlyActive = $0
            }
            let publisher = session!.publisher(for: basicRequest, errorParser: nil) as AnyPublisher<TestResponse, Error>
            let exp = expectation(description: "get request")
            let sub = publisher.sink(receiveCompletion: { _ in
                exp.fulfill()
            }, receiveValue: { _ in })
            waitForExpectations(timeout: 1.0, handler: nil)
            expect(isCurrentlyActive).to(beFalse())
            print("\(sub.hashValue)")
        }
    }

#endif
