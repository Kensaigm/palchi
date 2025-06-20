// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "PALCHI",
    platforms: [
        .iOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: "5.8.1")
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