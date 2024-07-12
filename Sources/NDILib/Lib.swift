//
//  Lib.swift
//
//
//  Created by Kota on 7/10/R6.
//
@_exported import NDISDK
@usableFromInline
final class NDILib {
	@usableFromInline
	let instance: NDIlib_v5
	private init() {
		instance = NDIlib_v5_load().unsafelyUnwrapped.pointee
		precondition(instance.initialize(), "Library has not been initialized")
	}
	deinit {
		instance.destroy()
	}
}
extension NDILib {
	@usableFromInline
	static let shared = NDILib()
}
extension NDILib {
	@inline(__always)
	@inlinable
	func create(description: UnsafePointer<NDIlib_find_create_t>) -> Optional<NDIlib_find_instance_t> {
		instance.find_create_v2(description)
	}
	@inline(__always)
	@inlinable
	func destroy(find object: NDIlib_find_instance_t) {
		instance.find_destroy(object)
	}
	@inline(__always)
	@inlinable
	func wait(with object: NDIlib_find_instance_t, milliseconds: UInt32) -> Bool {
		instance.find_wait_for_sources(object, milliseconds)
	}
	@inline(__always)
	@inlinable
	func get(with object: NDIlib_find_instance_t, milliseconds: UInt32) -> UnsafeBufferPointer<NDIlib_source_t> {
		var count = 0 as UInt32
		let start = instance.find_get_sources(object, &count, milliseconds)
		return.init(start: start, count: .init(count))
	}
	@inline(__always)
	@inlinable
	func get(with object: NDIlib_find_instance_t) -> UnsafeBufferPointer<NDIlib_source_t> {
		var count = 0 as UInt32
		let start = instance.find_get_current_sources(object, &count)
		return.init(start: start, count: .init(count))
	}
}
extension NDILib {
	@inline(__always)
	@inlinable
	func create(description: UnsafePointer<NDIlib_recv_create_v3_t>) -> Optional<NDIlib_recv_instance_t> {
		instance.recv_create_v3(description)
	}
	@inline(__always)
	@inlinable
	func destroy(recv object: NDIlib_recv_instance_t) {
		instance.recv_destroy(object)
	}
	@inline(__always)
	@inlinable
	func connect(with object: NDIlib_recv_instance_t, source: UnsafePointer<NDIlib_source_t>) {
		instance.recv_connect(object, source)
	}
	@inline(__always)
	@inlinable
	func capture(with object: NDIlib_recv_instance_t,
				 video: Optional<UnsafeMutablePointer<NDIlib_video_frame_v2_t>>,
				 audio: Optional<UnsafeMutablePointer<NDIlib_audio_frame_v3_t>>,
				 metadata: Optional<UnsafeMutablePointer<NDIlib_metadata_frame_t>>,
				 timeout: UInt32) -> NDIlib_frame_type_e {
		instance.recv_capture_v3(object, video, audio, metadata, timeout)
	}
	@inline(__always)
	@inlinable
	func video(with object: NDIlib_recv_instance_t, timeout: UInt32) -> Optional<NDIlib_video_frame_v2_t> {
		var frame = NDIlib_video_frame_v2_t()
		return instance.recv_capture_v3(object, &frame, .none, .none, timeout) == NDIlib_frame_type_video ? .some(frame) : .none
	}
	@inline(__always)
	@inlinable
	func audio(with object: NDIlib_recv_instance_t, timeout: UInt32) -> Optional<NDIlib_audio_frame_v3_t> {
		var frame = NDIlib_audio_frame_v3_t()
		return instance.recv_capture_v3(object, .none, &frame, .none, timeout) == NDIlib_frame_type_audio ? .some(frame) : .none
	}
	@inline(__always)
	@inlinable
	func metadata(with object: NDIlib_recv_instance_t, timeout: UInt32) -> Optional<NDIlib_metadata_frame_t> {
		var frame = NDIlib_metadata_frame_t()
		return instance.recv_capture_v3(object, .none, .none, &frame, timeout) == NDIlib_frame_type_metadata ? .some(frame) : .none
	}
	@inline(__always)
	@inlinable
	func free(with object: NDIlib_recv_instance_t, frame: NDIlib_video_frame_v2_t) {
		withUnsafePointer(to: frame) {
			instance.recv_free_video_v2(object, $0)
		}
	}
	@inline(__always)
	@inlinable
	func free(with object: NDIlib_recv_instance_t, frame: NDIlib_audio_frame_v3_t) {
		withUnsafePointer(to: frame) {
			instance.recv_free_audio_v3(object, $0)
		}
	}
	@inline(__always)
	@inlinable
	func free(with object: NDIlib_recv_instance_t, frame: NDIlib_metadata_frame_t) {
		withUnsafePointer(to: frame) {
			instance.recv_free_metadata(object, $0)
		}
	}
}
extension NDILib {
	@inline(__always)
	@inlinable
	func create(description: UnsafePointer<NDIlib_send_create_t>) -> Optional<NDIlib_send_instance_t> {
		instance.send_create(description)
	}
	@inline(__always)
	@inlinable
	func destroy(send object: NDIlib_send_instance_t) {
		instance.send_destroy(object)
	}
	@inline(__always)
	@inlinable
	func send(with object: NDIlib_send_instance_t, video frame: UnsafePointer<NDIlib_video_frame_v2_t>) {
		instance.send_send_video_async_v2(object, frame)
	}
	@inline(__always)
	@inlinable
	func send(with object: NDIlib_send_instance_t, audio frame: UnsafePointer<NDIlib_audio_frame_v3_t>) {
		instance.send_send_audio_v3(object, frame)
	}
	@inline(__always)
	@inlinable
	func send(with object: NDIlib_send_instance_t, metadata frame: UnsafePointer<NDIlib_metadata_frame_t>) {
		instance.send_send_metadata(object, frame)
	}
}
extension NDIlib_FourCC_type_e: CustomStringConvertible {
	public var description: String {
		withUnsafeBytes(of: self) {
			String(bytes: $0, encoding: .ascii) ?? ""
		}
	}
}
