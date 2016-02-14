//
//  Fetch.swift
//  Fetch
//
//  Created by David Hardiman on 13/02/2016.
//  Copyright © 2016 David Hardiman. All rights reserved.
//

import Foundation

private extension Request {
    func urlRequest() -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: url)
        if let headers = headers {
            request.allHTTPHeaderFields = headers
        }
        if let body = body {
            request.HTTPBody = body
        }
        return request
    }
}

private func makeRequest<T: Parsable>(request: Request, method: String, completion: Result<T> -> Void) {
    let request = request.urlRequest()
    request.HTTPMethod = method
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
        if let error = error {
            completion(.Failure(error))
            return
        }
        if let actualResponse = response as? NSHTTPURLResponse,
            data = data {
                completion(T.parse(fromData: data, withStatus: actualResponse.statusCode))
        }
    }
    task.resume()
}

/**
 Make a HTTP GET request for the resource specified by `request`
 
 - parameter request:    The request to make
 - parameter completion: The callback to call on completion
 */
public func get<T: Parsable>(request: Request, completion: Result<T> -> Void) {
    makeRequest(request, method: "GET", completion: completion)
}

/**
 Make a HTTP POST request for the resource specified by `request`
 
 - parameter request:    The request to make
 - parameter completion: The callback to call on completion
 */
public func post<T: Parsable>(request: Request, completion: Result<T> -> Void) {
    makeRequest(request, method: "POST", completion: completion)
}