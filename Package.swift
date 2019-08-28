// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UB",
    products: [
       .library(
            name: "UB",
            targets: ["UB"]),
    ],
    dependencies: [],
    targets: [
       .target(
            name: "UB",
            dependencies: []),
        .testTarget(
            name: "UBTests",
            dependencies: ["UB"])
    ]
)
