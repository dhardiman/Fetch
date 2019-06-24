//
//  Session+Combine.swift
//  Fetch-iOS
//
//  Created by David Hardiman on 21/06/2019.
//  Copyright © 2019 David Hardiman. All rights reserved.
//

#if canImport(Combine)

    import Combine
    import Foundation

    extension Session {
        @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
        public func publisher<T: Parsable>(for request: Request, errorParser: ErrorParsing.Type?) -> AnyPublisher<T, Error> {
            activityMonitor.incrementCount()
            return session.dataTaskPublisher(for: request.urlRequest())
                .mapError(handleActivityMonitorOnError)
                .tryMap { data, response -> T in
                    defer {
                        self.activityMonitor.decrementCount()
                    }
                    return try self.result(from: data, urlResponse: response, request: request, errorParser: errorParser).get()
                }
                .receive(on: responseQueue)
                .eraseToAnyPublisher()
        }

        func handleActivityMonitorOnError(_ error: URLError) -> URLError {
            activityMonitor.decrementCount()
            return error
        }
    }

#endif
