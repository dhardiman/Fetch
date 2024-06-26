//
//  HTTPFormPostRequest.swift
//  Fetch
//
//  Created by Sebastian Skuse on 17/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

import Foundation

public protocol HTTPFormPostRequest: Request {
    var jsonBody: [String: String] { get }
}

public extension HTTPFormPostRequest {

    var method: HTTPMethod {
        return .post
    }

    var body: Data? {
        return jsonBody.keyValueHTTPBody
    }
}

private extension Dictionary where Key == String, Value == String {

    var keyValueHTTPBody: Data? {
        var components = URLComponents()
        components.queryItems = self.reduce([URLQueryItem]()) { strings, param in
            let item = URLQueryItem(name: param.key, value: param.value.addingPostBodyEncoding())
            var output = strings
            output.append(item)
            return output
        }
        return components.query?.data(using: .utf8)
    }
}

private extension String {

    func addingPostBodyEncoding() -> String {
        var allowedCharacters = CharacterSet.urlQueryAllowed
        // RFC 3986
        allowedCharacters.remove(charactersIn: ":#[]@!$&'()*+,;=")
        return addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? self
    }
}
