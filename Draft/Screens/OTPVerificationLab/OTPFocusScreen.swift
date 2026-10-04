//
//  OTPFocusScreen.swift
//  Draft
//
//  Specification — chưa triển khai logic OTP.
//
//  TODO — So sánh tự focus khi vào màn hình với tap-to-focus.
//  Cho đóng bàn phím bằng nút Xong và mở lại mà không mất mã.
//  Trên màn hình nhỏ, input, lỗi và nút Verify vẫn nhìn thấy khi bàn phím mở.
//  Vào lại bài tập thì bắt đầu demo mới.
//  Kiểm tra chuyển focus, bàn phím ngoài, đóng và mở lại bàn phím.

import SwiftUI

struct OTPFocusScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Focus & keyboard")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        OTPFocusScreen()
    }
}
