//
//  Source.swift
//
//
//  Created by Kota on 7/10/R6.
//
public typealias NDISource = NDIlib_source_t
extension NDISource {
	@inlinable
	public var name: String {
		.init(cString: p_ndi_name)
	}
	@inlinable
	public var url: String {
		.init(cString: p_url_address)
	}
	@inlinable
	public var ip: String {
		.init(cString: p_ip_address)
	}
}
extension NDISource: CustomStringConvertible {
	public var description: String {
		name
	}
}
