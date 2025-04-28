// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "RestEasy",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "RestEasy",
            targets: ["RestEasy"]),
    ],
    targets: [
        .target(
            name: "RestEasy",
            path: "Sources",
            publicHeadersPath: ""
        )
    ],
    swiftLanguageVersions: [.v5]
)
