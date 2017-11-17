//
//  ResultTests.swift
//  FetchTests
//
//  Created by David Hardiman on 17/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

import XCTest
import Nimble
import Fetch

struct ResultTestPayload {
    let identifier = "hello"
}

enum ResultTestError: Error {
    case anError
}

class ResultTests: XCTestCase {
    func testItIsPossibleToMapASuccessfulResult() {
        let success = Result<ResultTestPayload>.success(ResultTestPayload())
        guard case .success(let string) = success.map({ $0.identifier }) else {
            return fail("Expected some success")
        }
        expect(string).to(equal("hello"))
    }

    func testAFailureMapsToTheExistingError() {
        let failure = Result<ResultTestPayload>.failure(ResultTestError.anError)
        guard case .failure(let error) = failure.map({ $0.identifier }) else {
            return fail("Expected an error")
        }
        expect(error as? ResultTestError).to(equal(ResultTestError.anError))
    }
}
