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

     - parameter response: The response that was received.
     - parameter errorParser: Object used to parse errors
     */
    static func parse(response: Response, errorParser: ErrorParsing.Type?) -> Result<Self>

}

public struct Response {

    /// The data received
    public let data: Data?

    /// The HTTP status code received
    public let status: Int

    /// The HTTP headers received
    public let headers: [String: String]?

    /// A userInfo dictionary attached to the request.
    public let userInfo: [String: Any]?

    /// The request this response was created from.
    public let originalRequest: Request
}
