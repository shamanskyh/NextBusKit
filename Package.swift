import PackageDescription

let package = Package(
    name: "NextBusKit",
    dependencies: [
        .Package(url: "https://github.com/tid-kijyun/Kanna.git", majorVersion: 2)
    ]
)
