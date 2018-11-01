//
//  ResponseErrorTests.swift
//  Fetch-iOS
//
//  Created by David Hardiman on 02/01/2018.
//  Copyright © 2018 David Hardiman. All rights reserved.
//

@testable import Fetch
import Nimble
import XCTest

class ResponseErrorTests: XCTestCase {
    func testStatusCodeErrorsHaveALocalisedString() {
        let codeError = ResponseError.statusCode(404) as Error
        expect(codeError.localizedDescription).to(equal("Status code error: 404"))
    }

    func testResponseErrorsHaveALocaliseedString() {
        let error = ResponseError.response(statusCode: 404, headers: ["hello": "world"]) as Error
        expect(error.localizedDescription).to(equal("Response error - Status Code: 404"))
    }
}
