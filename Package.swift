// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "LayoffRunway",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "LayoffRunway", targets: ["LayoffRunway"])
    ],
    targets: [
        .executableTarget(
            name: "LayoffRunway",
            path: "Sources"
        )
    ]
)
