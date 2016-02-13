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
protocol Parsable {
    
    /**
     Parses an object from the supplied data
     
     - parameter data:   The data retrieved
     - parameter status: The HTTP status code retrieved
     */
    static func parse(fromData data: NSData, withStatus status: Int) -> Self
    
    /// Does this object represent a successful fetch?
    var successful: Bool { get }
    
}