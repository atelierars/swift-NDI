//
//  main.swift
//
//
//  Created by Kota on 7/14/R6.
//
import AVFoundation
import NDILib
guard let filePath = CommandLine.arguments.dropFirst().first else {
	preconditionFailure("Specify Path for Asset via CLI arguments")
}
let screen = AVPlayerItemVideoOutput(outputSettings: [
	kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
])
let playerItem = AVPlayerItem(asset: .init(url: .init(filePath: filePath)))
playerItem.add(screen)

let player = AVPlayer(playerItem: playerItem)
let sender = NDISend(video: true)
let timer = DispatchSource.makeTimerSource(queue: .main)
timer.setRegistrationHandler {
	player.isMuted = true
	player.playImmediately(atRate: 1)
}
timer.setEventHandler {
	if let lastFrame = screen.copyPixelBuffer(forItemTime: player.currentTime(), itemTimeForDisplay: .none) {
		sender.send(frame: lastFrame)
	}
}
timer.schedule(deadline: .now(), repeating: 1001 / 300000.0)
timer.resume()
withExtendedLifetime((timer, playerItem), RunLoop.main.run)
