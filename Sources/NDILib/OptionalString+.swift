//
//  OptionalString+.swift
//
//
//  Created by Kota on 7/10/R6.
//
extension Optional where Wrapped == String {
	@inlinable
	func withOptionalCString<Result>(body: (Optional<UnsafePointer<CChar>>) throws -> Result) rethrows -> Result {
		switch self {
		case.none:
			try body(.none)
		case.some(let some):
			try some.withCString(body)
		}
	}
}
