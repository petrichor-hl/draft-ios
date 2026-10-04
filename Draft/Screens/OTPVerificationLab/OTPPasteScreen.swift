//
//  OTPPasteScreen.swift
//  Draft
//
//  Specification — chưa triển khai logic OTP.
//
//  TODO — So sánh paste ở single field, segmented appearance và separate fields.
//  Cho chọn mã 4 hoặc 6 chữ số; giữ nguyên số 0 đầu.
//  Loại bỏ khoảng trắng và dấu gạch nối trong mã được paste.
//  Từ chối nội dung còn ký tự ngoài chữ số hoặc dài hơn cấu hình; báo lỗi bằng chữ.
//  Separate fields: paste đủ mã thay toàn bộ; mã ngắn điền từ ô focus nếu vừa chỗ.
//  Kiểm tra thay vùng chọn, xóa, paste mã có định dạng, chữ cái và mã quá dài.

import SwiftUI

struct OTPPasteScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Paste & replacement")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        OTPPasteScreen()
    }
}
