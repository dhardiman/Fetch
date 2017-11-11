//
//  Request.swift
//  Fetch
//
//  Created by David Hardiman on 13/02/2016.
//  Copyright © 2016 David Hardiman. All rights reserved.
//

import Foundation

/**
 *  Simple struct representing a network request
 */
public struct Request {

    /// The URL to fetch
    public let url: URL

    /// The headers for the request
    public let headers: [String: String]?

    /// The body of the request
    public let body: Data?

    public init(url: URL, headers: [String: String]?, body: Data?) {
        self.url = url
        self.headers = headers
        self.body = body
    }

    public init(url: URL) {
        self.init(url: url, headers: nil, body: nil)
    }
}
