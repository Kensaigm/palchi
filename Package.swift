// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "PALCHI",
    platforms: [
        .iOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0")
    ],
    targets: [
        .target(
            name: "PALCHI",
            dependencies: [
                "Alamofire"
            ],
            path: "PalChiApp"
        )
    ]
)