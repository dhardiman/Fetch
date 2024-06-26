//
//  Cancellable.swift
//  Fetch
//
//  Created by Seb Skuse on 26/06/2024.
//  Copyright © 2024 David Hardiman. All rights reserved.
//

import Foundation

/// Protocol describing an operation that can be cancelled
public protocol Cancellable {
    
    /// The underlying progress object for the cancellable task.
    var progress: Progress { get }

    /// Cancel the operation
    func cancel()
}

extension URLSessionTask: Cancellable {}
