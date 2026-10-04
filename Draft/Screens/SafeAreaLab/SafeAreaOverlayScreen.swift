//
//  SafeAreaOverlayScreen.swift
//  Draft
//

import SwiftUI

struct SafeAreaOverlayScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("overlay")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SafeAreaOverlayScreen()
    }
}
