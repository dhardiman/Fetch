//
//  Fetch.swift
//  Fetch
//
//  Created by David Hardiman on 13/02/2016.
//  Copyright © 2016 David Hardiman. All rights reserved.
//

import Foundation

private extension Request {
    private func urlRequest(method: String) -> NSURLRequest {
        let request = NSMutableURLRequest(URL: url)
        if let headers = headers {
            request.allHTTPHeaderFields = headers
        }
        if let body = body {
            request.HTTPBody = body
        }
        request.HTTPMethod = method
        return request
    }
}

private func makeRequest<T: Parsable>(request: Request, method: String, session: NSURLSession, responseQueue: NSOperationQueue, completion: Result<T> -> Void) {
    let request = request.urlRequest(method)
    let task = session.dataTaskWithRequest(request) { (data, response, error) in
        if let error = error {
            completion(.Failure(error))
            return
        }
        guard let actualResponse = response as? NSHTTPURLResponse else {
            fatalError("Response is not an HTTP response")
        }
        let result = T.parse(fromData: data, withStatus: actualResponse.statusCode)
        responseQueue.addOperationWithBlock() {
            completion(result)
        }
    }
    task.resume()
}

/**
 Make a HTTP GET request for the resource specified by `request`
 
 - parameter request:    The request to make
 - parameter completion: The callback to call on completion
 */
public func get<T: Parsable>(request: Request, session: NSURLSession = NSURLSession.sharedSession(), responseQueue: NSOperationQueue = NSOperationQueue.mainQueue(), completion: Result<T> -> Void) {
    makeRequest(request, method: "GET", session: session, responseQueue: responseQueue, completion: completion)
}

/**
 Make a HTTP POST request for the resource specified by `request`
 
 - parameter request:    The request to make
 - parameter completion: The callback to call on completion
 */
public func post<T: Parsable>(request: Request, session: NSURLSession = NSURLSession.sharedSession(), responseQueue: NSOperationQueue = NSOperationQueue.mainQueue(), completion: Result<T> -> Void) {
    makeRequest(request, method: "POST", session: session, responseQueue: responseQueue, completion: completion)
}
