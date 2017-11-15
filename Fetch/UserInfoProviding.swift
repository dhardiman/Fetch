//
//  UserInfoProviding.swift
//  Fetch
//
//  Created by Sebastian Skuse on 15/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

import Foundation

/// Describes something that can provide a userInfo dictionary.
/// If a Request conforms to UserInfoProviding information will
/// be passed through to the Parsable.
public protocol UserInfoProviding {
    var userInfo: [String: Any]? { get }
}
