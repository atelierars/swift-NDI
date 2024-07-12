//
//  Duration+.swift
//
//
//  Created by Kota on 7/10/R6.
//
extension Duration {
	@inlinable
	var milliseconds: Int64 {
		components.seconds * 1_000 + components.attoseconds / 1_000_000_000_000_000
	}
}
