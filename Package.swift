// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription
let unsafeLinkerFlags = [
	.unsafeFlags([
		"-L/Library/NDI SDK for Apple/lib/macOS",
		"-L/Library/NDI SDK for Apple/lib/iOS",
		"-L/Library/NDI SDK for Apple/lib/tvOS",
	])
] as [LinkerSetting]
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
				/* Forbidden to use unsafe flags within standard app projects 😭 */
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
			name: "Example-Receiver",
			dependencies: ["NDILib"],
			path: "Snippets/Receiver"
		),
		.executableTarget(
			name: "Example-Sender-Camera",
			dependencies: ["NDILib"],
			path: "Snippets/Camera"
		),
		.executableTarget(
			name: "Example-Sender-Player",
			dependencies: ["NDILib"],
			path: "Snippets/Player"
		),
		.executableTarget(
			name: "Example-Sender-QRCode",
			dependencies: ["NDILib"],
			path: "Snippets/QRCode"
		),
		.testTarget(
			name: "NDILibTests",
			dependencies: ["NDILib"]
		)
	]
)

