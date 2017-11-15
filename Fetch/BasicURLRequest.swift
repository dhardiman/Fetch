//
//  BasicURLRequest.swift
//  Fetch
//
//  Created by David Hardiman on 13/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

import Foundation

/// Simple implementation of `Request` for scenarios where you just need to perform
/// a request with a URL rather than creating specific domain requests
public struct BasicURLRequest: Request, UserInfoProviding {
    public let url: URL

    public let method: HTTPMethod

    public let headers: [String: String]?

    public let body: Data?

    public let userInfo: [String: Any]?

    public init(url: URL, method: HTTPMethod = .get, headers: [String: String]? = nil, body: Data? = nil, userInfo: [String: Any]? = nil) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.userInfo = userInfo
    }
}
