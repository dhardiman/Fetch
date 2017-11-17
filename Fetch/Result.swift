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
    public func map<U>(_ transform: (T) -> U) -> Result<U> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }
}
