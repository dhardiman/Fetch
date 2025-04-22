//
//  ParsableDecodableTests.swift
//  Fetch
//
//  Created by Dave Hardiman on 22/04/2025.
//

@testable import Fetch
import Nimble
import XCTest

struct TestDecodable: Decodable, Parsable {
    let name: String
    let age: Int
}

class ParsableDecodableTests: XCTestCase {
    func testItIsPossibleToParseADecodableItem() throws {
        let stubData = try! JSONSerialization.data(withJSONObject: ["name": "Dave", "age": 42], options: [])
        let response = Response(data: stubData, status: 200, headers: nil, userInfo: nil, originalRequest: BasicURLRequest(url: URL(string: "http://www.example.com")!))
        let result = TestDecodable.parse(response: response, errorParser: nil)
        switch result {
        case .success(let decodable):
            expect(decodable.name).to(equal("Dave"))
            expect(decodable.age).to(equal(42))
        case .failure(let error):
            throw error
        }
    }
    
    func testItReportsANetworkStatusError() throws {
        let response = Response(data: nil, status: 400, headers: nil, userInfo: nil, originalRequest: BasicURLRequest(url: URL(string: "http://www.example.com")!))
        let result = TestDecodable.parse(response: response, errorParser: nil)
        switch result {
        case .success:
            throw "Expected an error"
        case .failure(let error as NetworkError):
            switch error {
            case .httpError(let code, let url, _):
                expect(code).to(equal(400))
                expect(url.absoluteString).to(equal("http://www.example.com"))
            default:
                throw "Unexpected error: \(error)"
            }
        default:
            throw "Unexpected error: \(result)"
        }
    }
    
    func testItReportsNoData() throws {
        let response = Response(data: nil, status: 200, headers: nil, userInfo: nil, originalRequest: BasicURLRequest(url: URL(string: "http://www.example.com")!))
        let result = TestDecodable.parse(response: response, errorParser: nil)
        switch result {
        case .success:
            throw "Expected an error"
        case .failure(let error as NetworkError):
            switch error {
            case .noDataError:
                break
            default:
                throw "Unexpected error: \(error)"
            }
        default:
            throw "Unexpected error: \(result)"
        }
    }
    
    func testItReportsAnErrorParsingError() throws {
        let stubData = try! JSONSerialization.data(withJSONObject: ["title": "Sir", "age": 42], options: [])
        let response = Response(data: stubData, status: 200, headers: nil, userInfo: nil, originalRequest: BasicURLRequest(url: URL(string: "http://www.example.com")!))
        let result = TestDecodable.parse(response: response, errorParser: nil)
        switch result {
        case .success:
            throw "Expected an error"
        case .failure(let error as NetworkError):
            switch error {
            case .parseError(_):
                break
            default:
                throw "Unexpected error: \(error)"
            }
        default:
            throw "Unexpected error: \(result)"
        }
    }
}

extension String: @retroactive Error {
    public var localizedDescription: String {
        return self
    }
}
