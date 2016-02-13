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
        get(request) { (result: FetchResult<EstablishmentsResponse>) in
            switch result {
            case .Successful(let response):
                response.establishments.forEach { (est) in
                    print("\(est.name)")
                }
            default:
                print("Badness")
            }
        }
    }

}

struct Establishment {
    let address: String
    let id: Int
    let name: String
}

struct EstablishmentsResponse: Parsable {
    let establishments: [Establishment]
    
    private(set) var successful: Bool
    
    static func parse(fromData data: NSData, withStatus status: Int) -> EstablishmentsResponse {
        if status != 200 {
            return EstablishmentsResponse(establishments: [], successful: false)
        }
        do {
            if let parsedResponse = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [Dictionary<String, AnyObject>] {
                let establishments = parsedResponse.map { est -> Establishment in
                    let id = est["id"] as! Int
                    let address = est["address"] as! String
                    let name = est["name"] as! String
                    return Establishment(address: address, id: id, name: name)
                }
                return EstablishmentsResponse(establishments: establishments, successful: true)
            }
        } catch {}
        return EstablishmentsResponse(establishments: [], successful: false)
    }
}

