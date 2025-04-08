// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sottsass",
    platforms: [
        .iOS(.v18), .watchOS(.v9), .macOS(.v13)
    ],
    products: [
        .library(
            name: "Sottsass",
            targets: ["Sottsass"]
        )
    ],
    targets: [
        .target(
            name: "Sottsass",
            resources: [
                .copy("../Resources/Cassettes"),
                .copy("../Resources/Stickers"),
                .copy("../Resources/Fonts")
            ]
        )
    ]
)
