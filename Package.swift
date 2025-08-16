// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Fetch",
    platforms: [
        .iOS(.v13),
        .macOS(.v13),
    ],
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
