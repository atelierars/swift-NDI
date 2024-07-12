// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription
let package = Package(
	name: "NDI",
	platforms: [
		.tvOS(.v16),
		.iOS(.v16),
		.macOS(.v14)
	],
	products: [
		.library(
			name: "NDI",
			targets: ["NDILib"]
		),
	],
	targets: [
		.target(
			name: "NDILib",
			dependencies: ["NDISDK"],
			linkerSettings: [
				/* We cannot use unsafe flag for application 😭 */
//				.unsafeFlags([
//					"-L/Library/NDI SDK for Apple/lib/macOS",
//					"-L/Library/NDI SDK for Apple/lib/iOS",
//					"-L/Library/NDI SDK for Apple/lib/tvOS",
//				]),
				.linkedLibrary("ndi", .when(platforms: [.macOS])),
				.linkedLibrary("ndi_ios", .when(platforms: [.iOS])),
				.linkedLibrary("ndi_tvos", .when(platforms: [.tvOS])),
			]
		),
		.systemLibrary(
			name: "NDISDK"
		),
		.executableTarget(
			name: "Example-Sender",
			dependencies: ["NDILib"],
			path: "Snippets/Sender"
		),
		.executableTarget(
			name: "Example-Receiver",
			dependencies: ["NDILib"],
			path: "Snippets/Receiver"
		),
		.testTarget(
			name: "NDILibTests",
			dependencies: ["NDILib"]
		)
	]
)
