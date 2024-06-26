//
//  RequestTests.swift
//  FetchTests
//
//  Created by Seb Skuse on 26/06/2024.
//  Copyright © 2024 David Hardiman. All rights reserved.
//

@testable import Fetch
import Nimble
import XCTest

final class RequestTests: XCTestCase {

    func testItBuildsItsURLRequestCorrectly() {
        let request = TestRequest()
        let urlRequest = request.urlRequest(for: request.defaultURLRequest())
        expect(urlRequest.httpMethod).to(equal(HTTPMethod.get.rawValue))
        expect(urlRequest.url).to(equal(request.url))
        expect(urlRequest.allHTTPHeaderFields?["Accept-Puddings"]).to(equal("Cake/*"))
        expect(urlRequest.httpBody).to(equal(request.body))
    }

}

private struct TestRequest: Request {
    let url = URL(string: "http://www.greggwallace.com")!
    let method: HTTPMethod = .get
    let headers: [String: String]? = ["Accept-Puddings": "Cake/*"]
    let body: Data? = Data()
}
