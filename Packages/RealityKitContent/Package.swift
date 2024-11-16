// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "RealityKitContent",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "RealityKitContent",
            targets: ["RealityKitContent"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RealityKitContent",
            dependencies: [],
            path: "Sources", // Ensure the correct path points to your source files
            exclude: ["README.md"], // Exclude any non-code files if necessary
            resources: [] // Remove any resources if none exist
        ),
    ]
)
