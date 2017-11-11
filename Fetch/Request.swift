//
//  Request.swift
//  Fetch
//
//  Created by David Hardiman on 13/02/2016.
//  Copyright © 2016 David Hardiman. All rights reserved.
//

import Foundation

/**
 *  Simple protocol representing a network request
 */
public protocol Request {

    /// The URL to fetch
    var url: URL { get }

    var method: HTTPMethod { get }

    /// The headers for the request
    var headers: [String: String]? { get }

    /// The body of the request
    var body: Data? { get }
}
