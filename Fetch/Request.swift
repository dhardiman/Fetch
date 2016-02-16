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
    public let url: NSURL
    
    /// The headers for the request
    public let headers: [String: String]?
    
    /// The body of the request
    public let body: NSData?
    
    public init(url: NSURL, headers: [String: String]?, body: NSData?) {
        self.url = url
        self.headers = headers
        self.body = body
    }
    
    public init(url: NSURL) {
        self.init(url: url, headers: nil, body: nil)
    }
}
