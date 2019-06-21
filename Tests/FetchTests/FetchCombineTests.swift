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

    @available(iOS 13.0, *)
    extension FetchTests {
        func testItIsPossibleToMakeAGetRequestUsingAPublisher() {
            stubRequest(passingTest: { $0.url! == testURL && $0.httpMethod == "GET" })
            let publisher = session!.publisher(for: basicRequest, errorParser: nil) as AnyPublisher<TestResponse, Error>
            let exp = expectation(description: "get request")
            _ = publisher.sink {
                expect($0.name).to(equal("test name"))
                expect($0.desc).to(equal("test desc"))
                exp.fulfill()
            }
            waitForExpectations(timeout: 1.0, handler: nil)
        }

        func testSessionErrorsAreReturnedUsingAPublisher() {
            let testError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil)
            OHHTTPStubs.stubRequests(passingTest: { (request) -> Bool in
                return request.url! == testURL && request.httpMethod == "GET"
            }, withStubResponse: { (_) -> OHHTTPStubsResponse in
                return OHHTTPStubsResponse(error: testError)
            })
            let publisher = session!.publisher(for: basicRequest, errorParser: nil) as AnyPublisher<TestResponse, Error>
            let exp = expectation(description: "get request")
            _ = publisher.sink(receiveCompletion: {
                switch $0 {
                case .finished:
                    fail("Expected an error")
                case .failure(let error):
                    expect(error as NSError).to(equal(testError))
                }
                exp.fulfill()
            }, receiveValue: { _ in })
            waitForExpectations(timeout: 1.0, handler: nil)
        }

        func testItReturnsParsedErrorsCorrectlyUsingAPublisher() {
            stubRequest(statusCode: 400) { (request) -> Bool in
                return request.url! == testURL && request.httpMethod == "GET"
            }
            let exp = expectation(description: "get request")
            let publisher = session!.publisher(for: basicRequest, errorParser: CustomError.self) as AnyPublisher<NoDataResponse, Error>
            var receivedError: Error?
            _ = publisher.sink(receiveCompletion: {
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
        }
    }

#endif
