import PackageDescription

let package = Package(
    name: "LiFXSwiftKit",
    dependencies: [
    	.Package(url: "https://github.com/frajaona/socks.git", majorVersion: 1, minor: 0),
    ],
    exclude: ["Sources/LiFXCASSocket.swift", "Sources/UdpCASSocket.swift", "Sources/AppleScriptCommands"]
)