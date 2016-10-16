import PackageDescription

let package = Package(
    name: "LiFXSwiftKit",
    dependencies: [
    	.Package(url: "https://github.com/robbiehanson/CocoaAsyncSocket.git", majorVersion: 7, minor: 4, patch: 3),
    ]
)