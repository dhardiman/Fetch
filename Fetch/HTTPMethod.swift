//
//  HTTPMethod.swift
//  Fetch
//
//  Created by Dave Hardiman on 08/09/2016.
//  Copyright © 2016 David Hardiman. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
    case trace = "TRACE"
    case options = "OPTIONS"
    case connect = "CONNECT"
}
