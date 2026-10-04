//
//  FormKeyboardAvoidanceScreen.swift
//  Draft
//
//  TODO — Ô nhập gần đáy phải nhìn thấy khi bàn phím xuất hiện.
//  Thử ở cuối form, cỡ chữ lớn và màn hình ngang.

import SwiftUI

struct FormKeyboardAvoidanceScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Keyboard avoidance")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FormKeyboardAvoidanceScreen()
    }
}
