// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "project5",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMinor(from: "3.3.0")),
	.package(url: "https://github.com/vapor/leaf.git", .upToNextMinor(from: "3.0.0")),
	.package(url: "https://github.com/twostraws/SwiftGD.git", .upToNextMinor(from: "2.5.0"))
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "Leaf", "SwiftGD"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)

