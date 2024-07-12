//
//  Send.swift
//
//
//  Created by Kota on 7/10/R6.
//
import AVFoundation
public final class NDISend {
	public enum Error: Swift.Error {
		case unsupported(format: OSType)
		case `internal`(error: OSStatus)
	}
	@usableFromInline
	let instance: NDIlib_send_instance_t
	@inlinable
	public init(name entry: Optional<String> = .none, group: Optional<String> = .none, video: Bool = false, audio: Bool = false) {
		instance = entry.withOptionalCString { entry in
			group.withOptionalCString { group in
				withUnsafePointer(to: NDIlib_send_create_t(p_ndi_name: entry, p_groups: group, clock_video: video, clock_audio: audio), NDILib.shared.create(description:))
			}
		}.unsafelyUnwrapped
	}
	deinit {
		NDILib.shared.destroy(send: instance)
	}
}
extension NDISend {
	@inlinable
	public func send(frame: NDIlib_video_frame_v2_t) {
		withUnsafePointer(to: frame) {
			NDILib.shared.send(with: instance, video: $0)
		}
	}
}
extension NDISend {
	@inlinable
	public func send(frame: NDIlib_audio_frame_v3_t) {
		withUnsafePointer(to: frame) {
			NDILib.shared.send(with: instance, audio: $0)
		}
	}
}
extension NDISend {
	@inlinable
	public func send(frame: NDIlib_metadata_frame_t) {
		withUnsafePointer(to: frame) {
			NDILib.shared.send(with: instance, metadata: $0)
		}
	}
}
extension NDISend {
	@discardableResult
	public func send(frame video: CVPixelBuffer, metadata xml: Optional<String> = .none) -> Result<(), Error> {
		switch CVPixelBufferGetPixelFormatType(video) {
		case kCVPixelFormatType_422YpCbCr8 where CVPixelBufferLockBaseAddress(video, .readOnly) == kCVReturnSuccess:
			defer {
				CVPixelBufferUnlockBaseAddress(video, .readOnly)
			}
			return.success(xml.withOptionalCString {
				send(frame: NDIlib_video_frame_v2_t(
					xres: .init(CVPixelBufferGetWidth(video)),
					yres: .init(CVPixelBufferGetHeight(video)),
					FourCC: NDIlib_FourCC_video_type_UYVY,
					frame_rate_N: 0,
					frame_rate_D: 0,
					picture_aspect_ratio: 0,
					frame_format_type: NDIlib_frame_format_type_progressive,
					timecode: NDIlib_send_timecode_synthesize,
					p_data: CVPixelBufferGetBaseAddress(video)?.assumingMemoryBound(to: UInt8.self),
					.init(line_stride_in_bytes: .init(CVPixelBufferGetBytesPerRow(video))),
					p_metadata: $0,
					timestamp: 0)
				)
			})
		case kCVPixelFormatType_422YpCbCr_4A_8BiPlanar where CVPixelBufferLockBaseAddress(video, .readOnly) == kCVReturnSuccess:
			defer {
				CVPixelBufferUnlockBaseAddress(video, .readOnly)
			}
			return.success(xml.withOptionalCString {
				send(frame: NDIlib_video_frame_v2_t(
					xres: .init(CVPixelBufferGetWidthOfPlane(video, 0)),
					yres: .init(CVPixelBufferGetHeightOfPlane(video, 0)),
					FourCC: NDIlib_FourCC_video_type_UYVA,
					frame_rate_N: 0,
					frame_rate_D: 0,
					picture_aspect_ratio: 0,
					frame_format_type: NDIlib_frame_format_type_progressive,
					timecode: NDIlib_send_timecode_synthesize,
					p_data: CVPixelBufferGetBaseAddressOfPlane(video, 0)?.assumingMemoryBound(to: UInt8.self),
					.init(line_stride_in_bytes: .init(CVPixelBufferGetBytesPerRowOfPlane(video, 0))),
					p_metadata: $0,
					timestamp: 0)
				)
			})
		case kCVPixelFormatType_422YpCbCr16BiPlanarVideoRange where CVPixelBufferLockBaseAddress(video, .readOnly) == kCVReturnSuccess:
			defer {
				CVPixelBufferUnlockBaseAddress(video, .readOnly)
			}
			return.success(xml.withOptionalCString {
				send(frame: NDIlib_video_frame_v2_t(
					xres: .init(CVPixelBufferGetWidth(video)),
					yres: .init(CVPixelBufferGetHeight(video)),
					FourCC: NDIlib_FourCC_type_P216,
					frame_rate_N: 0,
					frame_rate_D: 0,
					picture_aspect_ratio: 0,
					frame_format_type: NDIlib_frame_format_type_progressive,
					timecode: NDIlib_send_timecode_synthesize,
					p_data: CVPixelBufferGetBaseAddressOfPlane(video, 0)?.assumingMemoryBound(to: UInt8.self),
					.init(line_stride_in_bytes: .init(CVPixelBufferGetBytesPerRowOfPlane(video, 0))),
					p_metadata: $0,
					timestamp: 0))
			})
		case
			kCVPixelFormatType_420YpCbCr8Planar where CVPixelBufferLockBaseAddress(video, .readOnly) == kCVReturnSuccess,
			kCVPixelFormatType_420YpCbCr8PlanarFullRange where CVPixelBufferLockBaseAddress(video, .readOnly) == kCVReturnSuccess:
			defer {
				CVPixelBufferUnlockBaseAddress(video, .readOnly)
			}
			return.success(xml.withOptionalCString {
				send(frame: NDIlib_video_frame_v2_t(
					xres: .init(CVPixelBufferGetWidth(video)),
					yres: .init(CVPixelBufferGetHeight(video)),
					FourCC: NDIlib_FourCC_video_type_I420,
					frame_rate_N: 0,
					frame_rate_D: 0,
					picture_aspect_ratio: 0,
					frame_format_type: NDIlib_frame_format_type_progressive,
					timecode: NDIlib_send_timecode_synthesize,
					p_data: CVPixelBufferGetBaseAddressOfPlane(video, 0)?.assumingMemoryBound(to: UInt8.self),
					.init(line_stride_in_bytes: .init(CVPixelBufferGetBytesPerRowOfPlane(video, 0))),
					p_metadata: $0,
					timestamp: 0))
			})
		case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange where CVPixelBufferLockBaseAddress(video, .readOnly) == kCVReturnSuccess:
			defer {
				CVPixelBufferUnlockBaseAddress(video, .readOnly)
			}
			return.success(xml.withOptionalCString {
				send(frame: NDIlib_video_frame_v2_t(
					xres: .init(CVPixelBufferGetWidth(video)),
					yres: .init(CVPixelBufferGetHeight(video)),
					FourCC: NDIlib_FourCC_video_type_NV12,
					frame_rate_N: 0,
					frame_rate_D: 0,
					picture_aspect_ratio: 0,
					frame_format_type: NDIlib_frame_format_type_progressive,
					timecode: NDIlib_send_timecode_synthesize,
					p_data: CVPixelBufferGetBaseAddressOfPlane(video, 0)?.assumingMemoryBound(to: UInt8.self),
					.init(line_stride_in_bytes: .init(CVPixelBufferGetBytesPerRowOfPlane(video, 0))),
					p_metadata: $0,
					timestamp: 0))
			})
		case kCVPixelFormatType_32BGRA where CVPixelBufferLockBaseAddress(video, .readOnly) == kCVReturnSuccess:
			defer {
				CVPixelBufferUnlockBaseAddress(video, .readOnly)
			}
			return.success(xml.withOptionalCString {
				send(frame: .init(
					xres: .init(CVPixelBufferGetWidth(video)),
					yres: .init(CVPixelBufferGetHeight(video)),
					FourCC: NDIlib_FourCC_video_type_BGRA,
					frame_rate_N: 0,
					frame_rate_D: 0,
					picture_aspect_ratio: 0,
					frame_format_type: NDIlib_frame_format_type_progressive,
					timecode: NDIlib_send_timecode_synthesize,
					p_data: CVPixelBufferGetBaseAddress(video)?.assumingMemoryBound(to: UInt8.self),
					.init(line_stride_in_bytes: .init(CVPixelBufferGetBytesPerRow(video))),
					p_metadata: $0,
					timestamp: 0))
			})
		case kCVPixelFormatType_32RGBA where CVPixelBufferLockBaseAddress(video, .readOnly) == kCVReturnSuccess:
			defer {
				CVPixelBufferUnlockBaseAddress(video, .readOnly)
			}
			return.success(xml.withOptionalCString {
				send(frame: NDIlib_video_frame_v2_t(
					xres: .init(CVPixelBufferGetWidth(video)),
					yres: .init(CVPixelBufferGetHeight(video)),
					FourCC: NDIlib_FourCC_video_type_RGBA,
					frame_rate_N: 0,
					frame_rate_D: 0,
					picture_aspect_ratio: 0,
					frame_format_type: NDIlib_frame_format_type_progressive,
					timecode: NDIlib_send_timecode_synthesize,
					p_data: CVPixelBufferGetBaseAddress(video)?.assumingMemoryBound(to: UInt8.self),
					.init(line_stride_in_bytes: .init(CVPixelBufferGetBytesPerRow(video))),
					p_metadata: $0,
					timestamp: 0))
			})
		case let other:
			return.failure(.unsupported(format: other))
		}
	}
}
extension NDISend {
	@discardableResult
	public func send(frame: AVAudioPCMBuffer, metadata xml: Optional<String> = .none) -> Result<(), Error> {
		switch frame.format.commonFormat {
		case.pcmFormatFloat32 where frame.format.isInterleaved:
				.success(xml.withOptionalCString {
					send(frame: NDIlib_audio_frame_v3_t(
						sample_rate: .init(frame.format.sampleRate),
						no_channels: .init(frame.format.channelCount),
						no_samples: .init(frame.frameLength),
						timecode: NDIlib_send_timecode_synthesize,
						FourCC: NDIlib_FourCC_audio_type_FLTP,
						p_data: frame.audioBufferList.pointee.mBuffers.mData?.assumingMemoryBound(to: UInt8.self),
						.init(channel_stride_in_bytes: .init(MemoryLayout<Float32>.stride)),
						p_metadata: $0,
						timestamp: 0))
				})
		case.pcmFormatFloat32 where frame.format.isStandard:
				.success(xml.withOptionalCString {
					send(frame: NDIlib_audio_frame_v3_t(
						sample_rate: .init(frame.format.sampleRate),
						no_channels: .init(frame.format.channelCount),
						no_samples: .init(frame.frameLength / frame.format.channelCount),
						timecode: NDIlib_send_timecode_synthesize,
						FourCC: NDIlib_FourCC_audio_type_FLTP,
						p_data: frame.audioBufferList.pointee.mBuffers.mData?.assumingMemoryBound(to: UInt8.self),
						.init(channel_stride_in_bytes: .init(UnsafeMutableAudioBufferListPointer(frame.mutableAudioBufferList).memoryStride ?? 0)),
						p_metadata: $0,
						timestamp: 0))
				})
		default:
				.failure(.internal(error: kAudioFormatUnsupportedDataFormatError))
		}
	}
}
extension NDISend {
	@discardableResult
	public func send(frame xml: String) -> Result<(), Error> {
		xml.withCString {
			.success(send(frame: NDIlib_metadata_frame_t(length: .init(xml.count), timecode: 0, p_data: .init(mutating: $0))))
		}
	}
}
extension UnsafeMutableAudioBufferListPointer {
	@inlinable
	var memoryStride: Optional<Int> {
		let Δ = zip(dropLast(), dropFirst()).compactMap {
			switch ($0.mData, $1.mData) {
			case let(.some(s), .some(t)):
				.some(s.distance(to: t))
			default:
				.none
			}
		}
		return Δ.dropFirst().reduce(Δ.first) { $1 == $0 ? $1 : .none }
	}
}
