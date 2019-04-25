//
//  ResultTests.swift
//  FetchTests
//
//  Created by David Hardiman on 17/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

import Fetch
import Nimble
import XCTest

struct ResultTestPayload {
    let identifier = "hello"

    func success() throws -> String {
        return identifier
    }

    func failure() throws -> String {
        throw ResultTestError.anError
    }
}

enum ResultTestError: Error {
    case anError
}

class ResultTests: XCTestCase {
    func testItIsPossibleToMapASuccessfulResult() {
        let success = FetchResult<ResultTestPayload>.success(ResultTestPayload())
        guard case .success(let string) = success.map({ $0.identifier }) else {
            return fail("Expected some success")
        }
        expect(string).to(equal("hello"))
    }

    func testAFailureMapsToTheExistingError() {
        let failure = FetchResult<ResultTestPayload>.failure(ResultTestError.anError)
        guard case .failure(let error) = failure.map({ $0.identifier }) else {
            return fail("Expected an error")
        }
        expect(error as? ResultTestError).to(equal(ResultTestError.anError))
    }

    func testItIsPossibleToMapASuccessfulResultUsingAThrowingTransform() throws {
        let success = FetchResult<ResultTestPayload>.success(ResultTestPayload())
        guard case .success(let string) = success.map({ try $0.success() }) else {
            return fail("Expected some success")
        }
        expect(string).to(equal("hello"))
    }

    func testItIsPossibleToMapAnExistingErrorUsingAThrowingTransform() {
        let failure = FetchResult<ResultTestPayload>.failure(ResultTestError.anError)
        guard case .failure(let error) = failure.map({ try $0.success() }) else {
            return fail("Expected an error")
        }
        expect(error as? ResultTestError).to(equal(ResultTestError.anError))
    }

    func testIfATransformThrowsItReturnsTheNewError() {
        let failure = FetchResult<ResultTestPayload>.success(ResultTestPayload())
        guard case .failure(let error) = failure.map({ try $0.failure() }) else {
            return fail("Expected an error")
        }
        expect(error as? ResultTestError).to(equal(ResultTestError.anError))
    }
}
