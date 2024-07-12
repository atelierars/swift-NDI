//
//  Source.swift
//
//
//  Created by Kota on 7/10/R6.
//
public final class NDISource {
	@usableFromInline
	let memory: NDISourceCollection
	@usableFromInline
	let object: NDIlib_source_t
	@inlinable
	init(memory mem: NDISourceCollection, source obj: NDIlib_source_t) {
		memory = mem
		object = obj
	}
}
extension NDISource {
	@inlinable
	public var name: String {
		.init(cString: object.p_ndi_name)
	}
	@inlinable
	public var url: String {
		.init(cString: object.p_url_address)
	}
	@inlinable
	public var ip: String {
		.init(cString: object.p_ip_address)
	}
}
extension NDISource: CustomStringConvertible {
	@inlinable
	public var description: String {
		name
	}
}
