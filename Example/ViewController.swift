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
        let url = URL(string: "https://dl.dropboxusercontent.com/u/42100549/establishments.json")!
        let request = Request(url: url)
        request.perform() { (result: Result<EstablishmentsResponse>) in
            switch result {
            case .success(let response):
                response.establishments.forEach { (est) in
                    print("\(est.name)")
                }
            case .failure(let error):
                print("Badness \(error)")
            }
        }
    }

}

enum EstablishmentParseError: Error {
    case non200Response
    case parseFailure
}

struct Establishment {
    let address: String
    let id: Int
    let name: String
}

struct EstablishmentsResponse {
    let establishments: [Establishment]
}

extension EstablishmentsResponse: Parsable {
    static func parse(fromData data: Data?, withStatus status: Int, headers: [String: String]?) -> Result<EstablishmentsResponse> {
        if status != 200 {
            return .failure(EstablishmentParseError.non200Response)
        }
        do {
            if let data = data, let parsedResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [Dictionary<String, AnyObject>] {
                let establishments = parsedResponse.map { est -> Establishment in
                    let id = est["id"] as! Int
                    let address = est["address"] as! String
                    let name = est["name"] as! String
                    return Establishment(address: address, id: id, name: name)
                }
                return .success(EstablishmentsResponse(establishments: establishments))
            }
        } catch {}
        return .failure(EstablishmentParseError.parseFailure)
    }
}

