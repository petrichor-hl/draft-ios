//
//  FormSubmissionScreen.swift
//  Draft
//
//  TODO — Trạng thái loading, chặn gửi lặp, thành công, lỗi server và thử lại.
//  Giữ dữ liệu đã nhập khi gửi thất bại.

import SwiftUI

struct FormSubmissionScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Submission")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FormSubmissionScreen()
    }
}
