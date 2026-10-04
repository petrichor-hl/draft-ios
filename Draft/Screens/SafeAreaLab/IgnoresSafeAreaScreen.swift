//
//  IgnoresSafeAreaScreen.swift
//  Draft
//

import SwiftUI

struct IgnoresSafeAreaScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("ignoresSafeArea")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        IgnoresSafeAreaScreen()
    }
}
