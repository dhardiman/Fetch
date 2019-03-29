// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Fetch",
    products: [
      .library(name: "Fetch", targets: ["Fetch"])
    ],
    dependencies: [],
    targets: [
      .target(name: "Fetch", dependencies: []),
      .testTarget(name: "FetchTests", dependencies: ["Fetch"])
    ],
    swiftLanguageVersions: [.v5]
)
