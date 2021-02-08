// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Apodini-SolarTime",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/tgymnich/SolarTime.git", from: "0.0.2"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.0.0"),
        .package(url: "https://github.com/Apodini/Apodini.git", .branch("headers"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Apodini-SolarTime",
            dependencies: [
                .product(name: "Apodini", package: "Apodini"),
                .product(name: "ApodiniREST", package: "Apodini"),
                .product(name: "ApodiniOpenAPI", package: "Apodini"),
                .product(name: "SolarTime", package: "SolarTime"),
                .product(name: "AsyncHTTPClient", package: "async-http-client")
            ]),
        .testTarget(
            name: "Apodini-SolarTimeTests",
            dependencies: ["Apodini-SolarTime"]),
    ]
)
