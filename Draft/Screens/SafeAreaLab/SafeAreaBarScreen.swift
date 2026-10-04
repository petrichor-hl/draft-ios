//
//  SafeAreaBarScreen.swift
//  Draft
//

import SwiftUI

struct SafeAreaBarScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("safeAreaBar")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SafeAreaBarScreen()
    }
}
