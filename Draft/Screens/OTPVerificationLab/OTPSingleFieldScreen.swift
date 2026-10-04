//
//  OTPSingleFieldScreen.swift
//  Draft
//
//  Specification — chưa triển khai logic OTP.
//
//  TODO — Một ô nhập có label và nút Verify; so sánh mã 4 và 6 chữ số.
//  Lưu mã dưới dạng chuỗi để giữ số 0 đầu. Chỉ nhận chữ số, giới hạn độ dài.
//  Disable Verify khi chưa đủ số ký tự; đủ ký tự chưa có nghĩa mã hợp lệ.
//  Kiểm tra gõ, xóa, thay vùng chọn, paste và mã bắt đầu bằng 0.

import SwiftUI

struct OTPSingleFieldScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Single field")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        OTPSingleFieldScreen()
    }
}
