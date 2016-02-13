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
struct Request {
    
    /// The URL to fetch
    let url: NSURL
    
    /// The headers for the request
    let headers: [String: String]?
    
    /// The body of the request
    let body: NSData?
}
