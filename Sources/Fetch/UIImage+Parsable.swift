//
//  UIImage+Parsable.swift
//  Fetch
//
//  Created by David Hardiman on 12/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

#if canImport(UIKit)

    import UIKit

    public enum ImageParseError: Error {
        case noDataReceived
        case imageParseFailed
    }

    /// Box structure to get around the error:
    /// Protocol 'Parsable' requirement 'parse(from:errorParser:context:)' cannot be satisfied by a non-final class ('UIImage') because it uses 'Self' in a non-parameter, non-result type position
    /// meaning we can't extend UIImage directly with `Parsable` as it's `open`
    public struct Image {
        public let image: UIImage
    }

    extension Image: Parsable {
        public static func parse(response: Response, errorParser: ErrorParsing.Type?) -> FetchResult<Image> {
            guard response.status < 400 else {
                return .failure(ResponseError.statusCode(response.status))
            }
            guard let data = response.data else {
                return .failure(ImageParseError.noDataReceived)
            }
            guard let image = UIImage(data: data) else {
                return .failure(ImageParseError.imageParseFailed)
            }
            return .success(Image(image: image))
        }
    }

#endif
