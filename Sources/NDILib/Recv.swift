//
//  Recv.swift
//
//
//  Created by Kota on 7/10/R6.
//
import AVFoundation
import NDISDK
public enum NDIRecvBandwidth: NDIlib_recv_bandwidth_e.RawValue {
	case metadtaOnly =        -10	// NDIlib_recv_bandwidth_metadata_only.rawValue
	case audioOnly   =         10	// NDIlib_recv_bandwidth_audio_only.rawValue
	case lowest      =          0	// NDIlib_recv_bandwidth_lowest.rawValue
	case highest     =        100	// NDIlib_recv_bandwidth_highest.rawValue
	case max         = 0x7fffffff	// NDIlib_recv_bandwidth_max.rawValue
}
public enum NDIRecvColorFormat: NDIlib_recv_color_format_e.RawValue {
	case brgxbrga =          0	// NDIlib_recv_color_format_BGRX_BGRA.rawValue
	case uyuvbgra =          1	// NDIlib_recv_color_format_UYVY_BGRA.rawValue
	case rgbxrgba =          2	// NDIlib_recv_color_format_RGBX_RGBA.rawValue
	case uyuvrgba =          3	// NDIlib_recv_color_format_UYVY_RGBA.rawValue
	case fastest  =        100	// NDIlib_recv_color_format_fastest.rawValue
	case best     =        101	// NDIlib_recv_color_format_best.rawValue
	case max      = 0x7fffffff	// NDIlib_recv_color_format_max.rawValue
}
public final class NDIRecv {
	@usableFromInline
	let instance: NDIlib_recv_instance_t
	@inlinable
	init(description: NDIlib_recv_create_v3_t) {
		instance = withUnsafePointer(to: description, NDILib.shared.create(description:)).unsafelyUnwrapped
	}
	deinit {
		NDILib.shared.destroy(recv: instance)
	}
}
extension NDIRecv {
	@inlinable
	public convenience init(colorFormat: NDIRecvColorFormat, bandwidth: NDIRecvBandwidth) {
		self.init(description: .init(
			source_to_connect_to: .init(),
			color_format: .init(colorFormat.rawValue),
			bandwidth: .init(bandwidth.rawValue),
			allow_video_fields: true,
			p_ndi_recv_name: .none))
	}
}
extension NDIRecv {
	@inlinable
	public func connect(to source: NDISource) {
		withUnsafePointer(to: source.object) {
			NDILib.shared.connect(with: instance, source: $0)
		}
	}
}
extension NDIRecv {
	public func capture(for timeout: Duration) -> Optional<CVPixelBuffer> {
		guard let frame = NDILib.shared.video(with: instance, timeout: .init(truncatingIfNeeded: timeout.milliseconds)) else {
			return.none
		}
		switch frame.FourCC {
		case NDIlib_FourCC_video_type_BGRX, NDIlib_FourCC_video_type_BGRA:
			var result: CVPixelBuffer?
			return CVPixelBufferCreateWithBytes(
				kCFAllocatorDefault,
				.init(frame.xres),
				.init(frame.yres),
				kCVPixelFormatType_32BGRA,
				frame.p_data,
				.init(frame.line_stride_in_bytes),
				{(obj, mem) in obj.map(UnsafeRawPointer.init).map(Unmanaged<NDIRecvVideo>.fromOpaque)?.release()},
				Unmanaged.passRetained(NDIRecvVideo(memory: self, buffer: frame)).toOpaque(),
				.none,
				&result) == kCVReturnSuccess ? result : .none
		case NDIlib_FourCC_video_type_RGBX, NDIlib_FourCC_type_RGBA:
			var result: CVPixelBuffer?
			return CVPixelBufferCreateWithBytes(
				kCFAllocatorDefault,
				.init(frame.xres),
				.init(frame.yres),
				kCVPixelFormatType_32RGBA,
				frame.p_data,
				.init(frame.line_stride_in_bytes),
				{(obj, mem) in obj.map(UnsafeRawPointer.init).map(Unmanaged<NDIRecvVideo>.fromOpaque)?.release()},
				Unmanaged.passRetained(NDIRecvVideo(memory: self, buffer: frame)).toOpaque(),
				.none,
				&result) == kCVReturnSuccess ? result : .none
		case NDIlib_FourCC_video_type_UYVY:
			var result: CVPixelBuffer?
			return CVPixelBufferCreateWithBytes(
				kCFAllocatorDefault,
				.init(frame.xres),
				.init(frame.yres),
				kCVPixelFormatType_422YpCbCr8,
				frame.p_data,
				.init(frame.line_stride_in_bytes),
				{(obj, mem) in obj.map(UnsafeRawPointer.init).map(Unmanaged<NDIRecvVideo>.fromOpaque)?.release()},
				Unmanaged.passRetained(NDIRecvVideo(memory: self, buffer: frame)).toOpaque(),
				.none,
				&result) == kCVReturnSuccess ? result : .none
		default:
			return.none
		}
	}
}
extension NDIRecv {
	public func capture(for timeout: Duration) -> Optional<AVAudioPCMBuffer> {
		guard let frame = NDILib.shared.audio(with: instance, timeout: .init(truncatingIfNeeded: timeout.milliseconds)) else {
			return.none
		}
		switch frame.FourCC {
		case NDIlib_FourCC_audio_type_FLTP where MemoryLayout<Float32>.stride == .init(frame.channel_stride_in_bytes):
			return AVAudioFormat(
				commonFormat: .pcmFormatFloat32,
				sampleRate: .init(frame.sample_rate),
				channels: .init(frame.no_channels),
				interleaved: true)
			.flatMap {
				let abl = AudioBufferList.allocate(maximumBuffers: 1)
				abl[0] = .init(
					mNumberChannels: .init(frame.no_channels),
					mDataByteSize: .init(frame.no_channels * frame.no_samples * .init(MemoryLayout<Float32>.stride)),
					mData: frame.p_data)
				return AVAudioPCMBuffer(pcmFormat: $0, bufferListNoCopy: abl.unsafePointer) { mem in
					NDILib.shared.free(with: self.instance, frame: frame)
					abl.unsafePointer.deallocate()
				}
			}
		case NDIlib_FourCC_audio_type_FLTP:
			return AVAudioFormat(
				commonFormat: .pcmFormatFloat32,
				sampleRate: .init(frame.sample_rate),
				channels: .init(frame.no_channels),
				interleaved: false)
			.flatMap {
				let abl = AudioBufferList.allocate(maximumBuffers: .init(frame.no_channels))
				for ch in 0..<abl.count {
					abl[ch] = .init(
						mNumberChannels: 1,
						mDataByteSize: .init(frame.no_samples * .init(MemoryLayout<Float32>.stride)),
						mData: frame.p_data.advanced(by: ch * .init(frame.channel_stride_in_bytes)))
				}
				return AVAudioPCMBuffer(pcmFormat: $0, bufferListNoCopy: abl.unsafePointer) { mem in
					NDILib.shared.free(with: self.instance, frame: frame)
					abl.unsafePointer.deallocate()
				}
			}
		default:
			return.none
		}
	}
}
private final class NDIRecvVideo {
	let memory: NDIRecv
	let buffer: NDIlib_video_frame_v2_t
	init(memory mem: NDIRecv, buffer buf: NDIlib_video_frame_v2_t) {
		memory = mem
		buffer = buf
	}
	deinit {
		NDILib.shared.free(with: memory.instance, frame: buffer)
	}
}
