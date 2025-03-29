// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ios-solana-example",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ios-solana-example",
            targets: ["ios-solana-example"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Web3Auth/Web3Auth-iOS-SDK.git", exact: "1.0.0"),
        .package(url: "https://github.com/p2p-org/solana-swift.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "ios-solana-example",
            dependencies: [
                .product(name: "Web3Auth", package: "Web3Auth-iOS-SDK"),
                .product(name: "Web3AuthCore", package: "Web3Auth-iOS-SDK"),
                .product(name: "SolanaSwift", package: "solana-swift")
            ]),
        .testTarget(
            name: "ios-solana-exampleTests",
            dependencies: ["ios-solana-example"]),
    ]
) 