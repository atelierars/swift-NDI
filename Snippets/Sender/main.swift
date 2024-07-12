//
//  Sender.swift
//
//
//  Created by Kota on 7/12/R6.
//
import AVFoundation
import NDILib

switch AVCaptureDevice.authorizationStatus(for: .video) {
case.authorized:
	break
case.notDetermined:
	AVCaptureDevice.requestAccess(for: .video) {
		precondition($0, "cannot use camera")
	}
case.denied, .restricted:
	preconditionFailure("camera is not authorized")
@unknown default:
	assertionFailure("not implemented")
}

guard let camera: AVCaptureDevice = .default(for: .video) else {
	preconditionFailure("cannot use default camera")
}

final class Sender: NSObject {
	let sender: NDISend
	let session: AVCaptureSession
	init(with camera: AVCaptureDevice) throws {
		// Create NDI Sender instance
		sender = .init(video: true)
		
		// Setup camera capture
		session = .init()
		super.init()
		
		session.beginConfiguration()
		
		precondition(session.canSetSessionPreset(.low), "low session is not available")
		session.canSetSessionPreset(.low)

		let source = try AVCaptureDeviceInput(device: camera)
		
		precondition(session.canAddInput(source), "Input device cannot be add")
		session.addInput(source)

		let target = AVCaptureVideoDataOutput()
		target.videoSettings = [
			kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_422YpCbCr8 // UYUV
//			kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange // NV12
//			kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA // BGRA or BGRX
//			kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32RGBA // RGBA or RGBX, it might not work with Apple Silicon
		]
		target.setSampleBufferDelegate(self, queue: .init(label: "aa.ndi.sender-snippet")) // serial-queue might be better
		
		precondition(session.canAddOutput(target), "Output cannot be established")
		session.addOutput(target)
		
		session.commitConfiguration()
		
		session.startRunning()
	}
	deinit {
		session.stopRunning()
	}
}
extension Sender: AVCaptureVideoDataOutputSampleBufferDelegate {
	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		switch CMSampleBufferGetImageBuffer(sampleBuffer) {
		case.some(let frame):
			// Send captured video frame with NDI
			sender.send(frame: frame)
		case.none:
			break
		}
	}
}
try withExtendedLifetime(Sender(with: camera), RunLoop.main.run)
