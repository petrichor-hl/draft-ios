//
//  SafeAreaPaddingScreen.swift
//  Draft
//

import SwiftUI

struct SafeAreaPaddingScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("safeAreaPadding")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SafeAreaPaddingScreen()
    }
}
