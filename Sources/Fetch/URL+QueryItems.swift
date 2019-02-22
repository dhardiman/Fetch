//
//  URL+QueryItems.swift
//  Fetch
//
//  Created by David Hardiman on 13/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

import Foundation

public extension URL {
    func appending(queryItems: [URLQueryItem]) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return self
        }
        components.queryItems = queryItems
        return components.url ?? self
    }
}
