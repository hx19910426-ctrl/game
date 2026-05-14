// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MaxDesktopPet",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "MaxCore", targets: ["MaxCore"]),
        .executable(name: "MaxDesktopPet", targets: ["MaxDesktopPet"])
    ],
    targets: [
        .target(name: "MaxCore"),
        .executableTarget(name: "MaxDesktopPet", dependencies: ["MaxCore"]),
        .testTarget(name: "MaxCoreTests", dependencies: ["MaxCore"])
    ]
)
