// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppCoordinator",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppCoordinator",
            targets: ["AppCoordinator"]
        ),
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../MarvelAPI"),
        .package(path: "../Networking"),
        .package(path: "../Features/CharacterList"),
        .package(path: "../Features/CharacterDetail"),
        .package(path: "../Features/ComicsList"),
        .package(path: "../Features/Favorites"),
        .package(path: "../Features/Search"),
        .package(path: "../Features/Settings")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppCoordinator",
            dependencies: [
                "Core",
                "MarvelAPI",
                "Networking",
                "CharacterList",
                "CharacterDetail",
                "ComicsList",
                "Favorites",
                "Search",
                "Settings"
            ]
        ),
        .testTarget(
            name: "AppCoordinatorTests",
            dependencies: ["AppCoordinator"]
        ),
    ]
)
