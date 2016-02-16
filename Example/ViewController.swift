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
        let url = NSURL(string: "https://dl.dropboxusercontent.com/u/42100549/establishments.json")!
        let request = Request(url: url)
        get(request) { (result: Result<EstablishmentsResponse>) in
            switch result {
            case .Success(let response):
                response.establishments.forEach { (est) in
                    print("\(est.name)")
                }
            case .Failure(let error):
                print("Badness \(error)")
            }
        }
    }

}

enum EstablishmentParseError: ErrorType {
    case Non200Response
    case ParseFailure
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
    static func parse(fromData data: NSData?, withStatus status: Int) -> Result<EstablishmentsResponse> {
        if status != 200 {
            return .Failure(EstablishmentParseError.Non200Response)
        }
        do {
            if let data = data, parsedResponse = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [Dictionary<String, AnyObject>] {
                let establishments = parsedResponse.map { est -> Establishment in
                    let id = est["id"] as! Int
                    let address = est["address"] as! String
                    let name = est["name"] as! String
                    return Establishment(address: address, id: id, name: name)
                }
                return .Success(EstablishmentsResponse(establishments: establishments))
            }
        } catch {}
        return .Failure(EstablishmentParseError.ParseFailure)
    }
}

