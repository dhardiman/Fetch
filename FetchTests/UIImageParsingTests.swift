//
//  UIImageParsingTests.swift
//  FetchTests
//
//  Created by David Hardiman on 12/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

@testable import Fetch
import Nimble
import XCTest

class UIImageParsingTests: XCTestCase {
    func testItReturnsAnImageForASuccessfulResponse() {
        let testBundle = Bundle(for: UIImageParsingTests.self)
        guard let testImage = UIImage(named: "image", in: testBundle, compatibleWith: nil),
            let data = testImage.pngData() else {
            return fail("Couldn't parse test image")
        }
        guard case .success(let image) = Image.parse(response: Response(data: data, status: 200, originalRequest: TestJSONRequest()), errorParser: nil) else {
            return fail("Expected a successful response")
        }
        expect(image.image.pngData()).to(equal(data))
    }

    func testItReturnsAnErrorForNonSuccessStatus() {
        guard case .failure(let error) = Image.parse(response: Response(data: nil, status: 400, originalRequest: TestJSONRequest()), errorParser: nil) else {
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
        guard case .failure(let error) = Image.parse(response: Response(data: Data(), status: 200, originalRequest: TestJSONRequest()), errorParser: nil) else {
            return fail("Expected a failure")
        }
        guard let parseError = error as? ImageParseError else {
            return fail("Expected a parse failure")
        }
        expect(parseError).to(equal(ImageParseError.imageParseFailed))
    }

    func testItReturnsAnErrorForNoImageData() {
        guard case .failure(let error) = Image.parse(response: Response(data: nil, status: 200, originalRequest: TestJSONRequest()), errorParser: nil) else {
            return fail("Expected a failure")
        }
        guard let parseError = error as? ImageParseError else {
            return fail("Expected a parse failure")
        }
        expect(parseError).to(equal(ImageParseError.noDataReceived))
    }
}

extension Response {
    init(data: Data?, status: Int, originalRequest: Request) {
        self.init(data: data, status: status, headers: nil, userInfo: nil, originalRequest: originalRequest)
    }
}
