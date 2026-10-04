//
//  SafeAreaBackgroundScreen.swift
//  Draft
//

import SwiftUI

struct SafeAreaBackgroundScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("background")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SafeAreaBackgroundScreen()
    }
}
