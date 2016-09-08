//
//  Request.swift
//  Fetch
//
//  Created by David Hardiman on 13/02/2016.
//  Copyright © 2016 David Hardiman. All rights reserved.
//

import Foundation

/**
 *  Simple struct representing a network request
 */
public struct Request {
    
    /// The URL to fetch
    public let url: URL
    
    /// The headers for the request
    public let headers: [String: String]?
    
    /// The body of the request
    public let body: Data?
    
    public init(url: URL, headers: [String: String]?, body: Data?) {
        self.url = url
        self.headers = headers
        self.body = body
    }
    
    public init(url: URL) {
        self.init(url: url, headers: nil, body: nil)
    }

    public func perform<T: Parsable>(method: HTTPMethod = .get, session: URLSession = URLSession.shared, responseQueue: OperationQueue = OperationQueue.main, completion: @escaping (Result<T>) -> Void) {
        let request = self.urlRequest(method.rawValue)
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let actualResponse = response as? HTTPURLResponse else {
                fatalError("Response is not an HTTP response")
            }
            let result = T.parse(fromData: data, withStatus: actualResponse.statusCode, headers: actualResponse.allHeaderFields as? [String: String])
            responseQueue.addOperation() {
                completion(result)
            }
        }) 
        task.resume()
    }
}
