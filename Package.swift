// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let frameworkURL = "https://github.com/dhardiman/Fetch/releases/download/5.1.1/Fetch.zip"
let frameworkChecksum = "354941bb077ebcf5822b538aa0c5a629fd6c5dc04c0009930396674b49355746"

let package = Package(
    name: "Fetch",
    platforms: [
        .iOS(.v17),
        .macOS(.v13),
    ],
    products: [
        .library(name: "Fetch", targets: ["Fetch"])
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "Fetch",
            url: frameworkURL,
            checksum: frameworkChecksum),
    ],
    swiftLanguageVersions: [.v5]
)
