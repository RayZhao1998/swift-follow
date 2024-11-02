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
            targets: ["FollowUI"])
    ],
    dependencies: [
        .package(name: "FollowAPI", path: "../FollowAPI"),
        .package(url: "https://github.com/onevcat/Kingfisher", exact: "8.1.0"),
        .package(url: "https://github.com/malcommac/SwiftDate", exact: "7.0.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup", exact: "2.7.5"),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", exact: "2.4.1"),
        .package(url: "https://github.com/LiveUI/Awesome", exact: "2.4.0"),
        .package(url: "https://github.com/attaswift/BigInt.git", exact: "5.5.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FollowUI",
            dependencies: [
                .product(name: "FollowAPI", package: "FollowAPI"),
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "SwiftDate", package: "SwiftDate"),
                .product(name: "SwiftSoup", package: "SwiftSoup"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                .product(name: "Awesome", package: "Awesome"),
                .product(name: "BigInt", package: "BigInt")
            ]),
        .testTarget(
            name: "FollowUITests",
            dependencies: ["FollowUI"]
        ),
    ]
)
