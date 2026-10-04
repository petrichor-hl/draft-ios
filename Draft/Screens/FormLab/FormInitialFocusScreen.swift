//
//  FormInitialFocusScreen.swift
//  Draft
//
//  TODO — Tự focus ô đầu tiên khi vào màn hình.
//  Xác định có focus lại khi quay về màn hình hay không.

import SwiftUI

struct FormInitialFocusScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Initial focus")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FormInitialFocusScreen()
    }
}
