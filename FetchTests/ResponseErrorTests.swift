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
        let codeError = ResponseError.statusCode(404)
        expect(codeError.localizedDescription).to(equal("Status code error: 404"))
    }
}
