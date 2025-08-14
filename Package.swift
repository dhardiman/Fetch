// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Fetch",
    products: [
      .library(name: "Fetch", type: .dynamic, targets: ["Fetch"])
    ],
    dependencies: [],
    targets: [
      .target(name: "Fetch", dependencies: [], resources: [.copy("Resources/PrivacyInfo.xcprivacy")]),
      .testTarget(name: "FetchTests", dependencies: ["Fetch"])
    ],
    swiftLanguageVersions: [.v5]
)
