//
//  HTTPMethod.swift
//  Fetch
//
//  Created by David Hardiman on 11/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
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
