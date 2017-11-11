//
//  ViewController.swift
//  Example
//
//  Created by David Hardiman on 13/02/2016.
//  Copyright © 2016 David Hardiman. All rights reserved.
//

import UIKit
import Fetch

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let request = EstablishmentRequest()
        request.perform { (result: Result<EstablishmentsResponse>) in
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
    let url = URL(string: "https://dl.dropboxusercontent.com/u/42100549/establishments.json")!

    let method = HTTPMethod.get

    let headers: [String: String]? = nil

    let body: Data? = nil
}

enum EstablishmentParseError: Error {
    case non200Response
    case parseFailure
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
    static func parse(from data: Data?, status: Int, headers: [String: String]?) -> Result<EstablishmentsResponse> {
        if status != 200 {
            return .failure(EstablishmentParseError.non200Response)
        }
        do {
            // swiftlint:disable force_cast
            if let data = data, let parsedResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: AnyObject]] {
                let establishments = parsedResponse.map { est -> Establishment in
                    let id = est["id"] as! Int
                    let address = est["address"] as! String
                    let name = est["name"] as! String
                    return Establishment(address: address, id: id, name: name)
                }
                return .success(EstablishmentsResponse(establishments: establishments))
            }
            // swiftlint:enable force_cast
        } catch {}
        return .failure(EstablishmentParseError.parseFailure)
    }
}
