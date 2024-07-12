//
//  Collection.swift
//
//
//  Created by Kota on 7/10/R6.
//
public final class NDISourceCollection {
	@usableFromInline
	let memory: NDIFind
	@usableFromInline
	let buffer: UnsafeBufferPointer<NDIlib_source_t>
	@inlinable
	init(memory mem: NDIFind, buffer buf: UnsafeBufferPointer<NDIlib_source_t>) {
		memory = mem
		buffer = buf
	}
}
extension NDISourceCollection: RandomAccessCollection {
	@inlinable
	public var startIndex: Int { buffer.startIndex }
	@inlinable
	public var endIndex: Int { buffer.endIndex }
	@inlinable
	public subscript(position: Int) -> NDISource {
		.init(memory: self, source: buffer[position])
	}
}
extension NDISourceCollection: CustomStringConvertible {
	@inlinable
	public var description: String {
		Array(buffer).description
	}
}
