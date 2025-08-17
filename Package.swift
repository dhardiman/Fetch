// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let frameworkURL = "https://github.com/dhardiman/Fetch/releases/download/5.1.0/Fetch.zip"
let frameworkChecksum = "64029b7d19d6d8113e2811d64e7c17f42ae464d6f13174d79df39e10c9903100"

let package = Package(
    name: "Fetch",
    platforms: [
        .iOS(.v13),
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
