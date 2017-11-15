//
//  UIImageParsingTests.swift
//  FetchTests
//
//  Created by David Hardiman on 12/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

import XCTest
import Nimble
@testable import Fetch

class UIImageParsingTests: XCTestCase {
    func testItReturnsAnImageForASuccessfulResponse() {
        let testBundle = Bundle(for: UIImageParsingTests.self)
        guard let testImage = UIImage(named: "image", in: testBundle, compatibleWith: nil),
            let data = UIImagePNGRepresentation(testImage) else {
            return fail("Couldn't parse test image")
        }
        guard case .success(let image) = Image.parse(from: data, status: 200, headers: nil, errorParser: nil, userInfo: nil) else {
            return fail("Expected a successful response")
        }
        expect(UIImagePNGRepresentation(image.image)).to(equal(data))
    }

    func testItReturnsAnErrorForNonSuccessStatus() {
        guard case .failure(let error) = Image.parse(from: nil, status: 400, headers: nil, errorParser: nil, userInfo: nil) else {
            return fail("Expected a failure")
        }
        guard let responseError = error as? ResponseError else {
            return fail("Expected a response failure")
        }
        guard case .statusCode(let status) = responseError else {
            return fail("Expected a status code error")
        }
        expect(status).to(equal(400))
    }

    func testItReturnsAParseErrorForBadImageData() {
        guard case .failure(let error) = Image.parse(from: Data(), status: 200, headers: nil, errorParser: nil, userInfo: nil) else {
            return fail("Expected a failure")
        }
        guard let parseError = error as? ImageParseError else {
            return fail("Expected a parse failure")
        }
        expect(parseError).to(equal(ImageParseError.imageParseFailed))
    }

    func testItReturnsAnErrorForNoImageData() {
        guard case .failure(let error) = Image.parse(from: nil, status: 200, headers: nil, errorParser: nil, userInfo: nil) else {
            return fail("Expected a failure")
        }
        guard let parseError = error as? ImageParseError else {
            return fail("Expected a parse failure")
        }
        expect(parseError).to(equal(ImageParseError.noDataReceived))
    }
}
