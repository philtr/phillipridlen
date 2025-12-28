// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "BlogAdmin",
  platforms: [.macOS(.v13)],
  products: [
    .executable(name: "BlogAdmin", targets: ["BlogAdmin"])
  ],
  dependencies: [
    .package(url: "https://github.com/jpsim/Yams.git", from: "6.2.0")
  ],
  targets: [
    .executableTarget(
      name: "BlogAdmin",
      dependencies: ["Yams"]
    )
  ]
)
