//
//  EncodableRequestTests.swift
//  Fetch
//
//  Created by drh on 14/02/2022.
//  Copyright © 2022 David Hardiman. All rights reserved.
//

import Foundation
@testable import Fetch
import Nimble
import XCTest

class EncodableRequestTests: XCTestCase {
    func testItConvertsItsJSONBodyToData() throws {
        let testRequest = TestEncodableRequest(encodableBody: StubEncodable(id: MockId(rawValue: "123"),
                                                                            field: "test",
                                                                            intField: 42))
        guard let data = testRequest.body else {
            return fail("Expected body data to not be nil")
        }
        let decoder = JSONDecoder()
        guard let receivedObject = try? decoder.decode(StubEncodable.self, from: data) else {
            return fail("Couldn't decode JSON data")
        }
        expect(receivedObject.id).to(equal(MockId(rawValue: "123")))
        expect(receivedObject.field).to(equal("test"))
        expect(receivedObject.intField).to(equal(42))
    }
}

struct TestEncodableRequest: EncodableRequest {
    var encodableBody: StubEncodable
    let url: URL = URL(string: "https://test.com")!
    let method = HTTPMethod.get
    let headers: [String: String]? = nil
}

// Something Swift-specific that would not be serializable with JSONSerializer
typealias MockId = RawStringIdentifier<StubEncodable>

struct StubEncodable: Codable {
    let id: MockId
    let field: String
    let intField: Int
}

struct RawStringIdentifier<T>: RawRepresentable, Codable, Hashable, Equatable {
    public typealias RawValue = String
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
