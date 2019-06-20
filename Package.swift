// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NextBusKit",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "NextBusKit",
            type: .static,
            targets: ["NextBusKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/shamanskyh/Kanna.git", .revision("fb9228b8ac4445b1d6fa9e721b618a3b05cc5cc6"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "NextBusKit",
            dependencies: ["Kanna"]),
    ]
)
