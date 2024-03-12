// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WebSocketClient",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "WebSocketClient",
            targets: ["WebSocketClient"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "WebSocketClient",
            dependencies: []),
        .testTarget(
            name: "WebSocketClientTests",
            dependencies: ["WebSocketClient"]),
    ]
)
