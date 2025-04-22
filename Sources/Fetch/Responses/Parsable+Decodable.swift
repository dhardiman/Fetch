//
//  Parsable+Decodable.swift
//  Fetch
//
//  Created by Dave Hardiman on 22/04/2025.
//  Copyright © 2025 David Hardiman. All rights reserved.
//

import Foundation

/// The failures that can occur when handling a network response.
public enum NetworkError: Error {
    /// HTTP status error, with code.
    case httpError(code: Int, url: URL, bodyDataText: String?)
    /// The response contained no usable data.
    case noDataError
    /// There was an error parsing the response data into the expected model object.
    case parseError(Error)
}

// MARK: - LocalizedError

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .httpError(code, url, bodyDataText):
            var errorDescription = "HTTP Error Code: \(code.description). URL: \(url.absoluteString)"
            if let bodyDataText {
                errorDescription.append(". Body: \(bodyDataText as NSString)")
            }
            return errorDescription
        case .noDataError:
            return "No data"
        case let .parseError(error):
            return error.localizedDescription
        }
    }
}

extension ISO8601DateFormatter {
    fileprivate static var fetch_formatterWithFractionalSeconds: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
}

nonisolated(unsafe) private let formatter: ISO8601DateFormatter = {
    return ISO8601DateFormatter.fetch_formatterWithFractionalSeconds
}()

extension JSONDecoder.DateDecodingStrategy {
    fileprivate static let fetch_iso8601WithFractionalSeconds = custom {
        let container = try $0.singleValueContainer()
        let string = try container.decode(String.self)

        guard let date = formatter.date(from: string) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
        }
        return date
    }
}

public extension Parsable where Self: Decodable {

    /// Parses a network response in to the receiver's type, if possible.
    /// Returns a failure result for common network related issues, such as HTTP
    /// errors or a lack of response data.
    /// - Parameters:
    ///   - response: The response to be parsed.
    ///   - errorParser: The type used to parse errors from the response, if
    ///   any.
    /// - Returns: The result of attempting to parse the given response.
    static func parse(response: Response, errorParser: ErrorParsing.Type?) -> FetchResult<Self> {
        guard response.status == 200 || response.status == 201 else {
            if let error = errorParser?.parseError(
                from: response.data,
                statusCode: response.status)
            {
                return .failure(error)
            }
            let bodyDataText = response.data.flatMap { String(data: $0, encoding: .utf8) }
            return .failure(NetworkError.httpError(code: response.status, url: response.originalRequest.url, bodyDataText: bodyDataText))
        }

        guard let data = response.data else {
            return .failure(NetworkError.noDataError)
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .fetch_iso8601WithFractionalSeconds
            let response = try decoder.decode(Self.self, from: data)
            return .success(response)
        } catch {
            return .failure(NetworkError.parseError(error))
        }
    }
}
