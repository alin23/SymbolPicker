// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SymbolPicker",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "SymbolPicker",
            targets: ["SymbolPicker"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SymbolPicker",
            dependencies: [
            ],
            path: "Sources/SymbolPicker",
            resources: [
                .process("Resources"),
            ]),
        .testTarget(
            name: "SymbolPickerTests",
            dependencies: ["SymbolPicker"]),
    ]
)
