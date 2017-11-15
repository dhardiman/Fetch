//
//  UIImage+Parsable.swift
//  Fetch
//
//  Created by David Hardiman on 12/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

import UIKit

public enum ImageParseError: Error {
    case noDataReceived
    case imageParseFailed
}

/// Box structure to get around the error:
/// Protocol 'Parsable' requirement 'parse(from:status:headers:errorParser:userInfo:)' cannot be satisfied by a non-final class ('UIImage') because it uses 'Self' in a non-parameter, non-result type position
/// meaning we can't extend UIImage directly with `Parsable` as it's `open`
public struct Image {
    public let image: UIImage
}

extension Image: Parsable {
    public static func parse(from data: Data?, status: Int, headers: [String: String]?, errorParser: ErrorParsing.Type?, userInfo: [String: Any]?) -> Result<Image> {
        guard status < 400 else {
            return .failure(ResponseError.statusCode(status))
        }
        guard let data = data else {
            return .failure(ImageParseError.noDataReceived)
        }
        guard let image = UIImage(data: data) else {
            return .failure(ImageParseError.imageParseFailed)
        }
        return .success(Image(image: image))
    }
}
