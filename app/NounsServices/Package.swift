// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NounsServices",
    platforms: [.macOS(.v10_15), .iOS(.v15), .watchOS(.v8)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "NounsServices",
            targets: ["NounsServices"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Boilertalk/Web3.swift.git",
            from: "0.5.0"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "NounsServices",
            dependencies: [
                .product(name: "Web3", package: "Web3.swift"),
                .product(name: "Web3PromiseKit", package: "Web3.swift"),
                .product(name: "Web3ContractABI", package: "Web3.swift"),
            ],
            path: "Sources"),
        .testTarget(
            name: "NounsServicesTests",
            dependencies: ["NounsServices"]),
    ]
)
