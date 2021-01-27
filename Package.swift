// swift-tools-version:5.3
import PackageDescription

let package = Package(
	name: "Swizzle",
	products: [
		.library(
			name: "Swizzle",
			targets: ["Swizzle"]
		)
	],
	targets: [
		.target(name: "Swizzle")
	]
)
