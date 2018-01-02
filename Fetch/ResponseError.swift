//
//  NetworkError.swift
//  Fetch
//
//  Created by David Hardiman on 12/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

import Foundation

/// Common errors that might be encountered from a response
///
/// - statusCodeError: The status code didn't match expected range. Payload is the status code received.
/// - response: The response was invalid. Payload contains the status code and the headers.
public enum ResponseError: Error {
    case statusCode(Int)
    case response(statusCode: Int, headers: [String: String])
}

extension ResponseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .statusCode(let code):
            return "Status code error: \(code)"
        case .response(let statusCode, _):
            return "Response error - Status Code: \(statusCode)"
        }
    }
}
