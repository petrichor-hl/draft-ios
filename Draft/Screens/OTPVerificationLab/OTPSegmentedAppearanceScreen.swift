//
//  OTPSegmentedAppearanceScreen.swift
//  Draft
//
//  Specification — chưa triển khai logic OTP.
//
//  TODO — Một input logic duy nhất, hiển thị mã dưới dạng các ô chữ số.
//  Hiển thị vị trí đang nhập, mã thiếu, mã đủ và trạng thái lỗi.
//  Tap các ô để focus input; giữ khả năng sửa và chọn nội dung.
//  Cho chọn độ dài 4 hoặc 6; so sánh thao tác với Single field.
//  VoiceOver đọc một input logic; không dùng màu làm dấu hiệu duy nhất.

import SwiftUI

struct OTPSegmentedAppearanceScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Segmented appearance")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        OTPSegmentedAppearanceScreen()
    }
}
