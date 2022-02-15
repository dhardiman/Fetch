//
//  EncodableRequest.swift
//  Fetch
//
//  Created by drh on 14/02/2022.
//  Copyright © 2022 David Hardiman. All rights reserved.
//

import Foundation

public protocol EncodableRequest: Request {
    associatedtype T: Encodable

    var encodableBody: T { get }
}

public extension EncodableRequest {
    var body: Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(encodableBody)
    }
}
