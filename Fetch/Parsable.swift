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
     - parameter errorParser: Object used to parse errors
     - parameter context: Contextual information about the response
     */
    static func parse(from data: Data?, errorParser: ErrorParsing.Type?, context: ParsableContext) -> Result<Self>

}

public struct ParsableContext {
    /// The HTTP status code received
    public let status: Int

    /// The HTTP method used to make this request.
    public let HTTPMethod: HTTPMethod

    /// The HTTP headers received
    public let headers: [String: String]?

    /// A userInfo dictionary attached to the request.
    public let userInfo: [String: Any]?
}
