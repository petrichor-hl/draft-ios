//
//  FormFocusedBorderScreen.swift
//  Draft
//
//  TODO — Đổi màu viền khi focus.
//  Xác định trạng thái nào ưu tiên khi ô vừa có focus vừa có lỗi.

import SwiftUI

struct FormFocusedBorderScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Focused border")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FormFocusedBorderScreen()
    }
}
