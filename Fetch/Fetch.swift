//
//  Fetch.swift
//  Fetch
//
//  Created by David Hardiman on 13/02/2016.
//  Copyright © 2016 David Hardiman. All rights reserved.
//

import Foundation

private extension Request {
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

private func makeRequest<T: Parsable>(_ request: Request, method: String, session: URLSession, responseQueue: OperationQueue, completion: @escaping (Result<T>) -> Void) {
    let request = request.urlRequest(method)
    let task = session.dataTask(with: request, completionHandler: { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        guard let actualResponse = response as? HTTPURLResponse else {
            fatalError("Response is not an HTTP response")
        }
        let result = T.parse(fromData: data, withStatus: actualResponse.statusCode, headers: actualResponse.allHeaderFields as? [String: String])
        responseQueue.addOperation {
            completion(result)
        }
    })
    task.resume()
}

/**
 Make a HTTP GET request for the resource specified by `request`

 - parameter request:    The request to make
 - parameter completion: The callback to call on completion
 */
public func get<T: Parsable>(_ request: Request, session: URLSession = URLSession.shared, responseQueue: OperationQueue = OperationQueue.main, completion: @escaping (Result<T>) -> Void) {
    makeRequest(request, method: "GET", session: session, responseQueue: responseQueue, completion: completion)
}

/**
 Make a HTTP POST request for the resource specified by `request`

 - parameter request:    The request to make
 - parameter completion: The callback to call on completion
 */
public func post<T: Parsable>(_ request: Request, session: URLSession = URLSession.shared, responseQueue: OperationQueue = OperationQueue.main, completion: @escaping (Result<T>) -> Void) {
    makeRequest(request, method: "POST", session: session, responseQueue: responseQueue, completion: completion)
}
