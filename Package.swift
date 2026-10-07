// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "iADB",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "ADBCore",
            targets: ["ADBCore"]
        ),
        .executable(
            name: "iADBApp",
            targets: ["iADBApp"]
        ),
    ],
    targets: [
        .target(
            name: "ADBCore",
            path: "Sources/ADBCore"
        ),
        .executableTarget(
            name: "iADBApp",
            dependencies: ["ADBCore"],
            path: "iADBApp"
        ),
        .testTarget(
            name: "ADBCoreTests",
            dependencies: ["ADBCore"],
            path: "Tests/ADBCoreTests"
        ),
    ]
)
