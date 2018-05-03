//
//  Response.swift
//  Fetch
//
//  Created by Sebastian Skuse on 03/05/2018.
//  Copyright © 2018 David Hardiman. All rights reserved.
//

import Foundation

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

    public init(data: Data?, status: Int, headers: [String: String]?, userInfo: [String: Any]?, originalRequest: Request) {
        self.data = data
        self.status = status
        self.headers = headers
        self.userInfo = userInfo
        self.originalRequest = originalRequest
    }
}
