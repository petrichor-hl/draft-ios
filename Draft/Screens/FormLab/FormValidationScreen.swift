//
//  FormValidationScreen.swift
//  Draft
//
//  TODO — Mandatory fields, email, độ dài và xác nhận mật khẩu.
//  Chọn thời điểm báo lỗi: khi nhập, rời ô hay submit.
//  Lỗi có mô tả bằng chữ; khi submit lỗi, đưa focus tới ô lỗi đầu tiên.

import SwiftUI

struct FormValidationScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Validation")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FormValidationScreen()
    }
}
