//
//  EdgesIgnoringSafeAreaScreen.swift
//  Draft
//

import SwiftUI

struct EdgesIgnoringSafeAreaScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("edgesIgnoringSafeArea")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        EdgesIgnoringSafeAreaScreen()
    }
}
