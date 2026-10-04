//
//  OTPSeparateFieldsScreen.swift
//  Draft
//
//  Specification — chưa triển khai logic OTP.
//
//  TODO — Mỗi chữ số một input; cho chọn độ dài 4 hoặc 6.
//  Nhập một chữ số thì chuyển focus sang ô tiếp theo.
//  Backspace ở ô có chữ số thì xóa ô đó; ở ô trống thì lùi và xóa ô trước.
//  Tap ô đã có chữ số để thay thế. Giữ mã bắt đầu bằng 0.
//  Dán đủ mã thì thay toàn bộ; mã ngắn điền từ ô focus nếu còn đủ chỗ.
//  Kiểm tra focus, backspace, paste, bàn phím ngoài và VoiceOver;
//  so sánh với một input hiển thị thành nhiều ô.

import SwiftUI

struct OTPSeparateFieldsScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Separate fields")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        OTPSeparateFieldsScreen()
    }
}
