//
//  JSONRequest.swift
//  Fetch
//
//  Created by David Hardiman on 12/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

import Foundation

public protocol JSONRequest: Request {
    var jsonBody: Any { get }
}

public extension JSONRequest {
    var body: Data? {
        return try? JSONSerialization.data(withJSONObject: jsonBody, options: [])
    }
}
