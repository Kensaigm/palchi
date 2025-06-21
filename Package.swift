// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "PALCHI",
    platforms: [
        .iOS(.v13)
    ],
    dependencies: [
        // No external dependencies - using native iOS frameworks only
    ],
    targets: [
        .target(
            name: "PALCHI",
            dependencies: [
                // No dependencies
            ],
            path: "PalChiApp",
            resources: [
                .process("Resources/Assets.xcassets"),
                .process("Resources/Colors.xcassets"),
                .process("Data/PalChiDataModel.xcdatamodeld"),
                .copy("App/Info.plist")
            ]
        )
    ]
)