//
//  main.swift
//
//
//  Created by Kota on 7/12/R6.
//
import SwiftUI
final class AppWindow: NSWindow, NSWindowDelegate, NSApplicationDelegate {
	convenience init() {
		self.init(contentViewController: NSHostingController(rootView: View()))
		self.delegate = self
	}
	func applicationDidFinishLaunching(_ notification: Notification) {
		makeKeyAndOrderFront(.none)
		center()
	}
	func windowWillClose(_ notification: Notification) {
		NSApplication.shared.terminate(notification)
	}
}
let window = AppWindow()
let app = NSApplication.shared
app.delegate = window
app.setActivationPolicy(.regular)
app.activate()
withExtendedLifetime(window, app.run)
