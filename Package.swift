// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "Tiddly",
  platforms: [.macOS(.v13)],
  targets: [
    .target(name: "TiddlyCore", swiftSettings: [.swiftLanguageMode(.v5)]),
    .executableTarget(name: "Tiddly", dependencies: ["TiddlyCore"], swiftSettings: [.swiftLanguageMode(.v5)]),
    .testTarget(name: "TiddlyCoreTests", dependencies: ["TiddlyCore"], swiftSettings: [.swiftLanguageMode(.v5)])
  ]
)
