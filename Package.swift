// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftUILayoutSandbox",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SwiftUILayoutSandbox",
            targets: ["SwiftUILayoutSandbox"]
        )
    ],
    targets: [
        .target(
            name: "SwiftUILayoutSandbox"
        ),
        .testTarget(
            name: "SwiftUILayoutSandboxTests",
            dependencies: ["SwiftUILayoutSandbox"]
        )
    ]
)
