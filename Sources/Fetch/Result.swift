//
//  Result.swift
//  Fetch
//
//  Created by David Hardiman on 14/02/2016.
//  Copyright © 2016 David Hardiman. All rights reserved.
//

import Foundation

/**
 The result of a fetch request

 - Successful: Represents a success
 - Failure:    Represents a failure
 */
public enum Result<T> {
    case success(T)
    case failure(Error)
}

public extension Result {

    /// Maps the successful value and returns a new result
    ///
    /// - Parameter transform: The transform block
    public func map<U>(_ transform: (T) -> U) -> Result<U> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }

    /// Attempts to map the successful value and return a new result.
    /// If the transform fails, the failure value is returned as .failure in
    /// the new result
    ///
    /// - Parameter transform: The transform block
    public func map<U>(_ transform: (T) throws -> U) -> Result<U> {
        switch self {
        case .success(let value):
            do {
                return .success(try transform(value))
            } catch {
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}
