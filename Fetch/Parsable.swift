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
     - parameter response: The response that was received.
     - parameter errorParser: Object used to parse errors
     */
    static func parse(from data: Data?, response: Response, errorParser: ErrorParsing.Type?) -> Result<Self>

}

public struct Response {
    /// The HTTP status code received
    public let status: Int

    /// The HTTP method used to make this request.
    public let HTTPMethod: HTTPMethod

    /// The HTTP headers received
    public let headers: [String: String]?

    /// A userInfo dictionary attached to the request.
    public let userInfo: [String: Any]?
}
