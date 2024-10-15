// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FollowUI",
    platforms: [.macOS(.v15), .iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FollowUI",
            targets: ["FollowUI"]),
    ],
    dependencies: [.package(name: "FollowAPI", path: "../FollowAPI"), .package(url: "https://github.com/onevcat/Kingfisher", exact: "8.1.0"), .package(url: "https://github.com/malcommac/SwiftDate", exact: "7.0.0")],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FollowUI", dependencies: [.product(name: "FollowAPI", package: "FollowAPI"), .product(name: "Kingfisher", package: "Kingfisher"), .product(name: "SwiftDate", package: "SwiftDate")]),
        .testTarget(
            name: "FollowUITests",
            dependencies: ["FollowUI"]
        ),
    ]
)
