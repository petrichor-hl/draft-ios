//
//  FormLeadingIconScreen.swift
//  Draft
//
//  TODO — Icon đầu ô nhập, căn theo nội dung và cỡ chữ.

import SwiftUI

struct FormLeadingIconScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Leading icon")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FormLeadingIconScreen()
    }
}
