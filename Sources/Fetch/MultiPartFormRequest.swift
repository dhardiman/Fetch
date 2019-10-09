//
//  MultiPartFormRequest.swift
//  Fetch
//
//  Created by David Hardiman on 09/10/2019.
//  Copyright © 2019 David Hardiman. All rights reserved.
//

import Foundation

public struct MultiPartFormRequest: Request {
    public var url: URL

    public let method: HTTPMethod

    public let headers: [String: String]?

    public let body: Data?

    public init(url: URL, method: HTTPMethod = .post, sections: [MultipartFormDataSection]) {
        self.url = url
        self.method = method
        let elements = [MultiPartFormHeader.marker] + sections.map { $0.data }
        self.body = elements.combined
        self.headers = [
            "Content-Type": MultiPartFormHeader.headerText
        ]
    }
}

struct MultiPartFormHeader {
    static let boundary = "__fetch_boundary_token__"
    static var headerText: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    static var marker: Data {
        "--\(boundary)\(newLine)".data(using: .utf8)!
    }
}

private let newLine = "\r\n"

public struct MultipartFormDataSection {
    let contentType: String
    let charset: String
    let name: String
    let filename: String
    let content: Data

    public init(contentType: String = "text/plain", charset: String = "utf-8", name: String, filename: String, content: Data) {
        self.contentType = contentType
        self.charset = charset
        self.name = name
        self.filename = filename
        self.content = content
    }

    var data: Data {
        let headers = [
            "Content-Type: \(contentType); charset=\(charset)",
            #"Content-Disposition: form-data; name="\#(name)";filename="\#(filename)""#
        ]
        var output = Data()
        output.append(headers.joined(separator: newLine).data(using: .utf8)!)
        output.append([newLine, newLine].joined().data(using: .utf8)!)
        output.append(content)
        output.append(newLine.data(using: .utf8)!)
        output.append(MultiPartFormHeader.marker)
        return output
    }
}

extension Array where Element == Data {
    var combined: Data {
        var output = Data()
        forEach {
            output.append($0)
        }
        return output
    }
}
