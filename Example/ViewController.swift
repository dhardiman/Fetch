//
//  ViewController.swift
//  Example
//
//  Created by David Hardiman on 13/02/2016.
//  Copyright © 2016 David Hardiman. All rights reserved.
//

import Fetch
import UIKit

class ViewController: UIViewController {
    let session = Session()

    override func viewDidLoad() {
        super.viewDidLoad()
        let request = EstablishmentRequest()
        session.perform(request) { (result: Result<EstablishmentsResponse>) in
            switch result {
            case .success(let response):
                response.establishments.forEach { est in
                    print("\(est.name)")
                }
            case .failure(let error):
                print("Badness \(error)")
            }
        }
    }
}

struct EstablishmentRequest: Request {
    let url = URL(string: "https://gist.githubusercontent.com/drhaynes/8532fa509bf1b518e37902fde0d2fe0e/raw/69a2b0e8e3fd237ced8ad063cdb57486aa93f831/establishments.json")!
    let method = HTTPMethod.get
    let headers: [String: String]? = nil
    let body: Data? = nil
}

enum EstablishmentParseError: Error, ErrorParsing {
    case non200Response
    case parseFailure

    static func parseError(from: Data?, statusCode: Int) -> Error? {
        if statusCode != 200 {
            return EstablishmentParseError.non200Response
        }
        return nil
    }
}

struct Establishment {
    let address: String
    let id: Int // swiftlint:disable:this identifier_name
    let name: String
}

struct EstablishmentsResponse {
    let establishments: [Establishment]
}

extension EstablishmentsResponse: Parsable {
    static func parse(response: Response, errorParser: ErrorParsing.Type?) -> Result<EstablishmentsResponse> {
        if response.status != 200 {
            if let error = errorParser?.parseError(from: response.data, statusCode: response.status) {
                return .failure(error)
            } else {
                return .failure(EstablishmentParseError.non200Response)
            }
        }
        do {
            // swiftlint:disable force_cast
            if let data = response.data, let parsedResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: AnyObject]] {
                let establishments = parsedResponse.map { est -> Establishment in
                    let identifier = est["id"] as! Int
                    let address = est["address"] as! String
                    let name = est["name"] as! String
                    return Establishment(address: address, id: identifier, name: name)
                }
                return .success(EstablishmentsResponse(establishments: establishments))
            }
            // swiftlint:enable force_cast
        } catch {}
        return .failure(EstablishmentParseError.parseFailure)
    }
}
