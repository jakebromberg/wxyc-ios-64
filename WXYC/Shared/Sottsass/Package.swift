// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sottsass",
    platforms: [
        .iOS(.v18)
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
                .process("Resources/Media"),
                .process("Resources/Stickers"),
                .process("Resources/Fonts")
            ]
        )
    ]
)
