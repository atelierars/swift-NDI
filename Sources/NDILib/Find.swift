//
//  Find.swift
//
//
//  Created by Kota on 7/10/R6.
//
public final class NDIFind {
	@usableFromInline
	let instance: NDIlib_find_instance_t
	@inlinable
	public init(group: Optional<String> = .none, local: Bool = false) {
		instance = group.withOptionalCString {
			withUnsafePointer(to: NDIlib_find_create_t(show_local_sources: local, p_groups: $0, p_extra_ips: .none), NDILib.shared.create(description:))
		}.unsafelyUnwrapped
	}
	deinit {
		NDILib.shared.destroy(find: instance)
	}
}
extension NDIFind {
	@inlinable
	@discardableResult
	public func wait(for duration: Duration) -> Bool {
		NDILib.shared.wait(with: instance, milliseconds: .init(truncatingIfNeeded: duration.milliseconds))
	}
}
extension NDIFind {
	@inlinable
	public func sources(for duration: Duration) -> NDISourceCollection {
		.init(memory: self, buffer: NDILib.shared.get(with: instance, milliseconds: .init(truncatingIfNeeded: duration.milliseconds)))
	}
	@inlinable
	public var sources: NDISourceCollection {
		.init(memory: self, buffer: NDILib.shared.get(with: instance))
	}
}
