# Fetch
[![Coverage Status](https://coveralls.io/repos/github/dhardiman/Fetch/badge.svg)](https://coveralls.io/github/dhardiman/Fetch)
[![Circle CI](https://circleci.com/gh/dhardiman/Fetch.svg?style=svg)](https://circleci.com/gh/dhardiman/Fetch)

Simple HTTP in Swift. Hides the boilerplate code. Fetch allows you to make protocol-based HTTP requests, whilst providing a custom class or struct capable of parsing the response in to model objects your app can understand. Makes everything simple to unit test without needing to resort to stubbing network connections or using asynchronous tests.

## `Request`
This is a protocol used to describe a request. Create implementations of this for any request you wish to make. For example, if you wanted to fetch a user record, you might create a request like

```swift
struct UserRequest: Request {
  let url: URL
  let method = HTTPMethod.get
  let data: Data? = nil
  let headers: [String: String]?
  
  init(userId: Int, token: String) {
    url = URL(string: "https://my-web-service.com/users/\(userId)")!
    headers = [
      "Authorization": "Bearer \(token)"
    ]
  }
}
```

## `Parsable`
This is the protocol to use for handling a response. It has a single function, `static func parse(response: Response, errorParser: ErrorParsing?) -> Result<Self>`, which is intended to interpret the response (containing the data, status code, original request and other associated information) received from the request. Implement this method to determine success or failure and to populate a model object with data. For example, if parsing a response from our user request above, you might create the following:

```swift
struct User {
  let id: Int
  let name: String
}

extension User: Parsable {
  enum UserError: Error {
    case statusCodeError
    case parseError
  }
  
  static func parse(response: Response, errorParser: ErrorParsing?) -> Result<User> {
    guard response.status == 200 else {
      // Parse data for any error message
      if let error = errorParser.parseError(from: response.data, status: response.status) {
        return .failure(error)
      }
      return .failure(UserError.statusCodeError)
    }
    guard let data = response.data, 
          let parsedResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: AnyObject]],
          let id = parsedResponse["id"] as? Int,
          let name = parsedResponse["name"] as? String else {
      return .failure(UserError.parseError)
    }
    return .success(User(id: id, name: name))
  }
}
```

## `RequestPerforming`
This protocol describes an object capable of actually making a request. It has a single function:
```swift
  @discardableResult
  func perform<T: Parsable>(_ request: Request, completion: @escaping (Result<T>) -> Void) -> Cancellable
```

It should take a request, begin peforming it, and return a cancellable reference to the operation being performed. There is an implementation of this protocol in Fetch, `Session`, which wraps `URLSession` to make simple data requests. You can supply `Session` with your own `URLSession` and `OperationQueue` to call back on, but by default it uses `URLSession.shared` and `OperationQueue.main`. You could also implement your own entirely, if you need custom behaviour. By using `RequestPerforming` it becomes simple to introduce a mock or spy to ensure that the correct requests are being made.

If making a request for a user, you might do something like:

```swift
protocol UserQueryable {
  func findUser(id: Int)
}

class UserFetcher: UserQueryable {
  let session: RequestPerforming
  
  init(session: RequestPerforming = Session()) {
    self.session = session
  }
  
  func findUser(id: Int) {
    let request = UserRequest(id: id, token: token)
    session.perform(request) { (result: Result<User>) in
      switch result {
      case .failure(let error):
        print("\(error)")
      case .success(let user):
        // handle successful response  
      }
    }
  }
}
```

## Example
There is an example app in the project which shows you how to implement `Parsable`. In production code, I'd obviously recommend using your favourite swift JSON parsing library.

## Using in your own project
The easiest way to use this library is via Carthage. Just add

    github "dhardiman/Fetch"
to your Cartfile.

When building and running tests locally, make sure to initialise Carthage dependencies with:

`carthage bootstrap --platform iOS`

## License
[MIT](LICENSE.md) 
