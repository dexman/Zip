// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Zip",
    products: [
        .library(
            name: "Zip",
            targets: ["Zip"]
        ),
    ],
    targets: [
        .target(
            name: "Minizip",
            dependencies: [],
            exclude: ["module"],
            linkerSettings: [
                .linkedLibrary("z")
        ]),
        .target(
            name: "Zip",
            dependencies: ["Minizip"]
        ),
        .testTarget(
            name: "ZipTests",
            dependencies: ["Zip"]
        ),
    ]
)
