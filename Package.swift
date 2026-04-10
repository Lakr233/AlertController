// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlertController",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15),
    ],
    products: [
        .library(name: "AlertController", targets: ["AlertController"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ktiays/GlyphixTextFx.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "AlertController",
            dependencies: ["GlyphixTextFx"],
            resources: [.process("Resources")]
        ),
    ]
)
