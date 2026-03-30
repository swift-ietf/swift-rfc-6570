// swift-tools-version:6.2

import PackageDescription

extension String {
    static let rfc6570: Self = "RFC 6570"
}

extension Target.Dependency {
    static var rfc6570: Self { .target(name: .rfc6570) }
}

let package = Package(
    name: "swift-rfc-6570",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26)
    ],
    products: [
        .library(name: "RFC 6570", targets: ["RFC 6570"])
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-dictionary-primitives"),
        .package(path: "../../swift-primitives/swift-ascii-primitives"),
        .package(path: "../swift-rfc-3986"),
    ],
    targets: [
        .target(
            name: "RFC 6570",
            dependencies: [
                .product(name: "Dictionary Primitives", package: "swift-dictionary-primitives"),
                .product(name: "ASCII Primitives", package: "swift-ascii-primitives"),
                .product(name: "RFC 3986", package: "swift-rfc-3986")
            ]
        ),
        .testTarget(
            name: "RFC 6570 Tests",
            dependencies: [
                "RFC 6570",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
    var foundation: Self { self + " Foundation" }
}

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
