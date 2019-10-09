//
//  MultiPartFormRequestTests.swift
//  Fetch
//
//  Created by David Hardiman on 09/10/2019.
//  Copyright © 2019 David Hardiman. All rights reserved.
//

@testable import Fetch
import Nimble
import XCTest

class MultiPartFormRequestTests: XCTestCase {
    func testItAddsTheBoundaryHeader() {
        let request = MultiPartFormRequest(url: testURL, sections: [])
        expect(request.headers?["Content-Type"]).to(equal("multipart/form-data; boundary=__fetch_boundary_token__"))
    }

    func testItConvertsSectionsForTheBodyCorrectly() {
        let request = MultiPartFormRequest(url: testURL, sections: [
            MultipartFormDataSection(name: "testfile", filename: "testfile.txt", content: "test".data(using: .utf8)!)
        ])
        let expectedString = "--\(MultiPartFormHeader.boundary)\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Disposition: form-data; name=\"testfile\";filename=\"testfile.txt\"\r\n\r\ntest\r\n--\(MultiPartFormHeader.boundary)\r\n"
        expect(request.body).to(equal(expectedString.data(using: .utf8)))
    }

    func testItConvertsSectionsForTheBodyCorrectlyWhenThereAreMultipleParts() {
        let request = MultiPartFormRequest(url: testURL, sections: [
            MultipartFormDataSection(name: "testfile", filename: "testfile.txt", content: "test".data(using: .utf8)!),
            MultipartFormDataSection(contentType: "test-type", charset: "testset", name: "second test", filename: "second-test.txt", content: "another-test".data(using: .utf8)!)
        ])
        let expectedString = "--\(MultiPartFormHeader.boundary)\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Disposition: form-data; name=\"testfile\";filename=\"testfile.txt\"\r\n\r\ntest\r\n--\(MultiPartFormHeader.boundary)\r\nContent-Type: test-type; charset=testset\r\nContent-Disposition: form-data; name=\"second test\";filename=\"second-test.txt\"\r\n\r\nanother-test\r\n--\(MultiPartFormHeader.boundary)\r\n"
        expect(request.body).to(equal(expectedString.data(using: .utf8)))
    }
}
