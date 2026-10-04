//
//  FormPasswordScreen.swift
//  Draft
//
//  TODO — Ẩn mật khẩu mặc định, eye button bật/tắt hiển thị.
//  Kiểm tra focus và nội dung nhập khi đổi chế độ.

import SwiftUI

struct FormPasswordScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Password visibility")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FormPasswordScreen()
    }
}
