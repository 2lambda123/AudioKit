// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AudioKit",
    platforms: [.macOS(.v12), .iOS(.v15), .tvOS(.v13)],
    products: [.library(name: "AudioKit", targets: ["AudioKit"])],
    dependencies: [.package(url: "https://github.com/apple/swift-atomics", from: .init(1, 0, 3))],
    targets: [
        .target(name: "AudioKit",
                dependencies: ["Utilities", .product(name: "Atomics", package: "swift-atomics")],
                swiftSettings: [
                  .unsafeFlags(["-experimental-performance-annotations"])
                ]),
        .target(name: "Utilities"),
        .testTarget(name: "AudioKitTests", dependencies: ["AudioKit"], resources: [.copy("TestResources/")]),
    ]
)
