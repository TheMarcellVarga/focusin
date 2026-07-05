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
            exclude: [
                "Resources/Assets.xcassets",
                "Resources/Info.plist",
                "Resources/Focusin.entitlements"
            ],
            resources: [
                .copy("Resources/Activities.json"),
                .copy("Resources/PrivacyInfo.xcprivacy")
            ]
        ),
        .testTarget(
            name: "FocusinTests",
            dependencies: ["Focusin"]
        )
    ]
)
