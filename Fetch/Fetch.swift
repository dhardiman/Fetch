//
//  Fetch.swift
//  Fetch
//
//  Created by David Hardiman on 13/02/2016.
//  Copyright © 2016 David Hardiman. All rights reserved.
//

import Foundation

private extension Request {
    func urlRequest() -> URLRequest {
        var request = URLRequest(url: url as URL)
        if let headers = headers {
            request.allHTTPHeaderFields = headers
        }
        if let body = body {
            request.httpBody = body
        }
        request.httpMethod = method.rawValue
        return request
    }
}

/// Protocol describing an operation that can be cancelled
public protocol Cancellable {

    /// Cancel the operation
    func cancel()
}

extension URLSessionTask: Cancellable {}

public extension Request {

    /// Make an HTTP request for the resource described by this `Request`
    ///
    /// - Parameters:
    ///   - session: The URL session to use
    ///   - responseQueue: The queue to  send the response on
    ///   - completion: The completion block to call with the response
    /// - Returns: A cancellable reference to the request operation
    @discardableResult
    public func perform<T: Parsable>(session: URLSession = URLSession.shared, responseQueue: OperationQueue = OperationQueue.main, completion: @escaping (Result<T>) -> Void) -> Cancellable {
        let task = session.dataTask(with: urlRequest(), completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let actualResponse = response as? HTTPURLResponse else {
                fatalError("Response is not an HTTP response")
            }
            let result = T.parse(from: data, status: actualResponse.statusCode, headers: actualResponse.allHeaderFields as? [String: String])
            responseQueue.addOperation {
                completion(result)
            }
        })
        task.resume()
        return task
    }
}
