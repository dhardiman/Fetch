//
//  Parsable.swift
//  Fetch
//
//  Created by David Hardiman on 13/02/2016.
//  Copyright © 2016 David Hardiman. All rights reserved.
//

import Foundation

/**
 *  Item that can parse data retrieved from a request
 */
public protocol Parsable {
    
    /**
     Parses an object from the supplied data
     
     - parameter data:    The data received
     - parameter status:  The HTTP status code received
     - parameter headers: The HTTP headers received
     */
    static func parse(fromData data: NSData?, withStatus status: Int, headers: [String: String]?) -> Result<Self>
    
}
