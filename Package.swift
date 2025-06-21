// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PALCHI",
    platforms: [
        .iOS(.v13)
    ],
    targets: [
        .target(
            name: "PALCHI",
            path: "PalChiApp",
            resources: [
                .process("Resources/Assets.xcassets"),
                .process("Resources/Colors.xcassets"),
                .process("Data/PalChiDataModel.xcdatamodeld")
            ],
            exclude: ["Info.plist"]
        )
    ]
)