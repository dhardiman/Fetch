//
//  FetchResult.swift
//  Fetch
//
//  Created by David Hardiman on 14/02/2016.
//  Copyright © 2016 David Hardiman. All rights reserved.
//

import Foundation

public typealias FetchResult<T> = Result<T, Error>

public extension FetchResult {

    /// Attempts to map the successful value and return a new result.
    /// If the transform fails, the failure value is returned as .failure in
    /// the new result
    ///
    /// - Parameter transform: The transform block
    func map<U>(_ transform: (Success) throws -> U) -> FetchResult<U> {
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
