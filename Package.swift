// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Focusin",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Focusin", targets: ["Focusin"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Focusin",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "FocusinTests",
            dependencies: ["Focusin"]
        )
    ]
)
