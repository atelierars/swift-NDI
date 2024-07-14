//
//  Source.swift
//
//
//  Created by Kota on 7/12/R6.
//
import SwiftUI
import CoreImage
import NDILib
final class Controller {
	@Published var nsImage: NSImage
	var current: String = ""
	let timer: DispatchSourceTimer
	let find: NDIFind
	let recv: NDIRecv
	init() {
		
		// NDI Source Finder which even finds local sender
		find = .init(local: true)
		
		// Create NDI Receiver to decode received frame
		recv = .init(colorFormat: .best)
		
		// Use nsimage as a container to hold received video frame
		nsImage = .init(size: .init(width: 256, height: 256))
		
		timer = DispatchSource.makeTimerSource(queue: .main)
		timer.setEventHandler(handler: handler)
		timer.schedule(deadline: .now(), repeating: 1001 / 30000.0)
		timer.resume()
		
	}
}
extension Controller: RandomAccessCollection {
	var startIndex: Int { 0 }
	var endIndex: Int { find.sources.count }
	subscript(position: Int) -> String {
		find.sources[position].name
	}
}
extension Controller {
	func receive(source name: String) {
		assert(Thread.isMainThread)
		guard let source = find.sources.first(where: { $0.name == name }) else { return }
		recv.connect(to: source)
	}
}
extension Controller {
	var selection: Binding<String> {
		.init(get: { [weak self] in
			guard let self else { return "" }
			return current
		}, set: { [weak self] name in
			guard let self, let source = find.sources.first(where: { $0.name == name }) else { return }
			current = name
			recv.connect(to: source)
		})
	}
}
extension Controller {
	func handler() {
		assert(Thread.isMainThread)
		guard let frame: CVPixelBuffer = recv.capture(for: .milliseconds(1001000 / 30000)) else {
			objectWillChange.send()
			return
		}
		let image = NSImage(size: .zero)
		image.addRepresentation(NSCIImageRep(ciImage: .init(cvImageBuffer: frame)))
		nsImage = image
	}
}
extension Controller: ObservableObject {}
