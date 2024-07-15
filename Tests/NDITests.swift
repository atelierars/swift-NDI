import XCTest
import AVFoundation
@testable import NDILib
final class NDILibTests: XCTestCase {
	func testScenario() {
		var buffer: CVPixelBuffer?
		XCTAssertEqual(CVPixelBufferCreate(kCFAllocatorDefault, 512, 512, kCVPixelFormatType_32BGRA, .none, &buffer), kCVReturnSuccess)
		guard let buffer else {
			XCTFail("No video frame has been allocated")
			return
		}
		let sender = NDISend(video: true)
		let timer = DispatchSource.makeTimerSource()
		let sent = XCTestExpectation(description: "sent")
		timer.setEventHandler {
			sender.send(frame: buffer)
			sent.fulfill()
		}
		timer.schedule(deadline: .now(), repeating: 1001 / 30000.0)
		timer.resume()
		defer {
			timer.cancel()
		}
		let finder = NDIFind(local: true)
		guard finder.wait(for: .seconds(1)), let source = finder.sources.first else {
			XCTFail("No video source has been found")
			return
		}
		let recv = NDIRecv(colorFormat: .uyuvbgra)
		recv.connect(to: source)
		wait(for: [sent], timeout: 0)
		let captured = Array<Duration>(repeating: .seconds(1), count: 16).compactMap(recv.capture(for:)) as Array<CVPixelBuffer>
		XCTAssertGreaterThan(captured.count, 0, "no video frame captured")
		XCTAssertTrue(captured.allSatisfy { CVPixelBufferGetPixelFormatType($0) == kCVPixelFormatType_32BGRA })
	}
	func testMilliseconds() {
		let value = Int64.random(in: 1...Int64.max)
		XCTAssertEqual(Duration.milliseconds(value).milliseconds, value)
	}
}
