//
//  FetchTests.swift
//  FetchTests
//
//  Created by David Hardiman on 13/02/2016.
//  Copyright © 2016 David Hardiman. All rights reserved.
//

import XCTest
@testable import Fetch

let testString = "{ \"name\": \"test name\", \"desc\": \"test desc\" }"

struct TestResponse: Parsable {
    enum Fail: ErrorType {
        case StatusFail
        case ParseFail
    }

    let name: String
    let desc: String

    static func parse(fromData data: NSData, withStatus status: Int) -> Result<TestResponse> {
        if status != 200 {
            return .Failure(Fail.StatusFail)
        }
        do {
            if let dict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: String] {
                return .Success(TestResponse(name: dict["name"]!, desc: dict["desc"]!))
            }
        } catch {}
        return .Failure(Fail.ParseFail)

    }
}

class FetchTests: XCTestCase {
    

    
}
