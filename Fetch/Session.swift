//
//  Session.swift
//  Fetch
//
//  Created by David Hardiman on 11/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

import Foundation

/// Protocol describing an object that can make requests
public protocol RequestPerforming {

    /// Make an HTTP request for the resource described by this `Request`
    ///
    /// - Parameters:
    ///   - request: The request to perform
    ///   - completion: The completion block to call with the response
    ///   - errorParser: Optional object to provide custom error parsing
    /// - Returns: A cancellable reference to the request operation
    @discardableResult
    func perform<T: Parsable>(_ request: Request, errorParser: ErrorParsing?, completion: @escaping (Result<T>) -> Void) -> Cancellable
}

public extension RequestPerforming {
    /// Make an HTTP request for the resource described by this `Request`
    ///
    /// - Parameters:
    ///   - request: The request to perform
    ///   - completion: The completion block to call with the response
    /// - Returns: A cancellable reference to the request operation
    @discardableResult
    func perform<T: Parsable>(_ request: Request, completion: @escaping (Result<T>) -> Void) -> Cancellable {
        return perform(request, errorParser: nil, completion: completion)
    }
}

/// Session for making requests using a URLSession
public class Session: RequestPerforming {
    private let session: URLSession
    private let responseQueue: OperationQueue

    public init(session: URLSession = .shared, responseQueue: OperationQueue = .main) {
        self.session = session
        self.responseQueue = responseQueue
    }

    @discardableResult
    public func perform<T: Parsable>(_ request: Request, errorParser: ErrorParsing?, completion: @escaping (Result<T>) -> Void) -> Cancellable {
        let task = session.dataTask(with: request.urlRequest(), completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let actualResponse = response as? HTTPURLResponse else {
                completion(.failure(SessionError.unknownResponseType))
                return
            }
            let result = T.parse(from: data, status: actualResponse.statusCode, headers: actualResponse.allHeaderFields as? [String: String], errorParser: errorParser)
            self.responseQueue.addOperation {
                completion(result)
            }
        })
        task.resume()
        return task
    }
}

enum SessionError: Error {
    case unknownResponseType
}

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
