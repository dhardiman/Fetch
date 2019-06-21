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
        @available(iOS 13.0, *)
        public func perform<T: Parsable>(_ request: Request, errorParser: ErrorParsing.Type?) -> AnyPublisher<T, Error> {
            let publisher = session.dataTaskPublisher(for: request.urlRequest())
                .tryMap { data, response -> T in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw SessionError.unknownResponseType
                    }
                    let userInfo = (request as? UserInfoProviding)?.userInfo
                    let response = Response(data: data, status: httpResponse.statusCode, headers: httpResponse.allHeaderFields as? [String: String], userInfo: userInfo, originalRequest: request)
                    return try T.parse(response: response, errorParser: errorParser).get()
                }
                .receive(on: responseQueue)
            return AnyPublisher(publisher)
        }
    }

#endif
