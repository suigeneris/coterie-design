// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "OursDesignSystem",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "OursDesignSystem", targets: ["OursDesignSystem"])
    ],
    targets: [
        .target(
            name: "OursDesignSystem",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "OursDesignSystemTests",
            dependencies: ["OursDesignSystem"]
        )
    ]
)
