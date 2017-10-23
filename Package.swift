import PackageDescription

let package = Package(
    name: "NextBusKit",
    dependencies: [
        .Package(url: "https://github.com/tid-kijyun/Kanna.git", revision: "9091f84ed0e39b7fa8536da98a1812c3456bc4e3")
    ]
)
