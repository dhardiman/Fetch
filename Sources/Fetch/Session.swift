//
//  Session.swift
//  Fetch
//
//  Created by David Hardiman on 11/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

import Foundation
#if canImport(Combine)
    import Combine
#endif

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
    func perform<T: Parsable>(_ request: Request, errorParser: ErrorParsing.Type?, completion: @escaping (FetchResult<T>) -> Void) -> Cancellable

    /// Cancels all outstanding tasks
    func cancelAllTasks()

    #if canImport(Combine)
        @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
        func publisher<T: Parsable>(for request: Request, errorParser: ErrorParsing.Type?) -> AnyPublisher<T, Error>
    #endif
}

public extension RequestPerforming {
    /// Make an HTTP request for the resource described by this `Request`
    ///
    /// - Parameters:
    ///   - request: The request to perform
    ///   - completion: The completion block to call with the response
    /// - Returns: A cancellable reference to the request operation
    @discardableResult
    func perform<T: Parsable>(_ request: Request, completion: @escaping (FetchResult<T>) -> Void) -> Cancellable {
        return perform(request, errorParser: nil, completion: completion)
    }
}

/// Session for making requests using a URLSession
public class Session: RequestPerforming {
    let session: URLSession
    let responseQueue: OperationQueue

    public init(session: URLSession = .shared, responseQueue: OperationQueue = .main) {
        self.session = session
        self.responseQueue = responseQueue
    }

    var tasks = [UUID: URLSessionTask]()
    let taskQueue = DispatchQueue(label: "me.davidhardiman.taskqueue")

    var activityMonitor: SessionActivityMonitor = .shared

    @discardableResult
    public func perform<T: Parsable>(_ request: Request, errorParser: ErrorParsing.Type?, completion: @escaping (FetchResult<T>) -> Void) -> Cancellable {
        let taskIdentifier = UUID()
        activityMonitor.incrementCount()
        let task = session.dataTask(with: request.urlRequest(), completionHandler: { data, response, error in
            self.taskQueue.sync {
                self.removeTask(for: taskIdentifier)
            }
            let result: FetchResult<T>
            defer {
                self.responseQueue.addOperation {
                    self.activityMonitor.decrementCount()
                    completion(result)
                }
            }
            if let error = error {
                result = .failure(error)
                return
            }
            do {
                result = try self.result(from: data, urlResponse: response, request: request, errorParser: errorParser)
            } catch {
                result = .failure(error)
            }
        })
        self.taskQueue.sync {
            tasks[taskIdentifier] = task
        }
        task.resume()
        return task
    }

    func result<T: Parsable>(from data: Data?, urlResponse: URLResponse?, request: Request, errorParser: ErrorParsing.Type?) throws -> FetchResult<T> {
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw SessionError.unknownResponseType
        }
        let userInfo = (request as? UserInfoProviding)?.userInfo
        let response = Response(data: data, status: httpResponse.statusCode, headers: httpResponse.allHeaderFields as? [String: String], userInfo: userInfo, originalRequest: request)
        return T.parse(response: response, errorParser: errorParser)
    }

    private func removeTask(for identifier: UUID) {
        tasks.removeValue(forKey: identifier)
    }

    public func cancelAllTasks() {
        self.taskQueue.sync {
            tasks.values.forEach { $0.cancel() }
            tasks.removeAll()
        }
    }
}

enum SessionError: Error {
    case unknownResponseType
}

extension Request {
    func urlRequest() -> URLRequest {
        var request = URLRequest(url: url)
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
