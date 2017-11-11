# Fetch
[![Coverage Status](https://coveralls.io/repos/github/dhardiman/Fetch/badge.svg?branch=master)](https://coveralls.io/github/dhardiman/Fetch?branch=master)
[![Circle CI](https://circleci.com/gh/dhardiman/Fetch.svg?style=svg)](https://circleci.com/gh/dhardiman/Fetch)

Simple HTTP in Swift. Hides the boilerplate code. Fetch allows you to make HTTP `get` and `post` requests, whilst providing a custom class or struct capable of parsing the response in to model objects your app can understand.

## `Parsable`
This is the protocol to use when creating a request. It has a single function, `static func parse(from data: Data?, status: Int, headers: [String: String]?) -> Result<Self>`, which is intended to interpret the data and status code received from the successful request. Implement this method to determine success or failure and to populate a model object with data.

## Example
There is an example app in the project which shows you how to implement `Parsable`. In production code, I'd obviously recommend using your favourite swift JSON parsing library.

## Using in your own project
The easiest way to use this library is via Carthage. Just add

    github "dhardiman/Fetch"

to your Cartfile

## License
[MIT](LICENSE.md) 
