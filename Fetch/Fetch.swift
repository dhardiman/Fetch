//
//  Fetch.swift
//  Fetch
//
//  Created by David Hardiman on 13/02/2016.
//  Copyright © 2016 David Hardiman. All rights reserved.
//

import Foundation

extension Request {
    func urlRequest(_ method: String) -> URLRequest {
        var request = URLRequest(url: url as URL)
        if let headers = headers {
            request.allHTTPHeaderFields = headers
        }
        if let body = body {
            request.httpBody = body
        }
        request.httpMethod = method
        return request
    }
}

/**
 Make a HTTP GET request for the resource specified by `request`
 
 - parameter request:    The request to make
 - parameter completion: The callback to call on completion
 */
public func get<T: Parsable>(_ request: Request, session: URLSession = URLSession.shared, responseQueue: OperationQueue = OperationQueue.main, completion: @escaping (Result<T>) -> Void) {
    request.perform(session: session, responseQueue: responseQueue, completion: completion)
}

/**
 Make a HTTP POST request for the resource specified by `request`
 
 - parameter request:    The request to make
 - parameter completion: The callback to call on completion
 */
public func post<T: Parsable>(_ request: Request, session: URLSession = URLSession.shared, responseQueue: OperationQueue = OperationQueue.main, completion: @escaping (Result<T>) -> Void) {
    request.perform(method: .post, session: session, responseQueue: responseQueue, completion: completion)
}
