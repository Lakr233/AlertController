// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AlertController",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(name: "AlertController", targets: ["AlertController"]),
    ],
    targets: [
        .target(
            name: "AlertController",
            resources: [.process("Resources")]
        ),
    ]
)
