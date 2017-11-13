//
//  ErrorParsing.swift
//  Fetch
//
//  Created by David Hardiman on 13/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

import Foundation

/// Describes something that can parse an error from received data and status.
/// Used to decouple the success and error parsing in cases where a request
/// might return the same model object on success but has a different set of
/// errors.
public protocol ErrorParsing {
    static func parseError(from data: Data?, statusCode: Int) -> Error?
}
