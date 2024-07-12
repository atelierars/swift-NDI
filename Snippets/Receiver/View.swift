//
//  File.swift
//  
//
//  Created by Kota on 7/12/R6.
//
import SwiftUI
struct View: SwiftUI.View {
	@StateObject var controller = Controller()
	var selection: Binding<String> {
		.init(get: { "" }, set: { _ = $0 })
	}
	var body: some SwiftUI.View {
		Group {
			Image(nsImage: controller.nsImage)
			Picker("Choose NDI source", selection: controller.selection) {
				ForEach(controller, id: \.self) { source in
					Text(source)
				}
			}	
		}
		.padding(20)
	}
}
