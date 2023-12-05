//
//  URL+QueryItems.swift
//  Fetch
//
//  Created by David Hardiman on 13/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

import Foundation

public extension URL {
    @available(iOS, introduced: 12.0, obsoleted: 16.0, message: "Use Foundation function")
    @available(tvOS, introduced: 12.0, obsoleted: 16.0, message: "Use Foundation function")
    @available(macOS, introduced: 10.11, obsoleted: 13.0, message: "Use Foundation function")
    func appending(queryItems: [URLQueryItem]) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return self
        }
        components.queryItems = queryItems
        return components.url ?? self
    }
}
