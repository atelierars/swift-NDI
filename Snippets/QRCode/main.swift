//
//  main.swift
//
//
//  Created by Kota on 7/14/R6.
//
import CoreImage
import NDILib
guard let generator = CIFilter(name: "CIQRCodeGenerator") else {
	preconditionFailure("No QRCodeGenerator created")
}
generator.setDefaults()
generator.setValue("https://github.com/atelierars/Swift-NDI".data(using: .utf8), forKey: "inputMessage")
guard let blueprint = generator.outputImage?.transformed(by: .init(scaleX: 16, y: 16)) else {
	preconditionFailure("No blueprint generated")
}
var screen: CVPixelBuffer?
guard CVPixelBufferCreate(kCFAllocatorDefault, .init(blueprint.extent.width), .init(blueprint.extent.height), kCVPixelFormatType_420YpCbCr8BiPlanarFullRange, .none, &screen) == kCVReturnSuccess, let screen else {
	preconditionFailure("No CVPixelBuffer allocated")
}
let renderer = CIContext()
let sender = NDISend(video: true)
let source = DispatchSource.makeTimerSource()
source.setEventHandler {
	renderer.render(blueprint, to: screen)
	sender.send(frame: screen)
}
source.schedule(deadline: .now(), repeating: 1)
source.resume()
withExtendedLifetime(source, RunLoop.current.run)
