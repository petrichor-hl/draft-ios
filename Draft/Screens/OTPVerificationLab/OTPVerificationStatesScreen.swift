//
//  OTPVerificationStatesScreen.swift
//  Draft
//
//  Specification — chưa triển khai logic OTP.
//
//  TODO — Mô phỏng thiếu mã, verifying, invalid, expired, temporary failure và success.
//  Cho chọn kết quả mô phỏng và response delay trong phần demo controls riêng.
//  So sánh nhấn Verify với tùy chọn tự submit khi đủ mã.
//  Chặn gửi lặp; giữ mã đã nhập khi gặp lỗi tạm thời để thử lại.
//  Bỏ qua kết quả cũ nếu mã hoặc phiên demo đã thay đổi.
//  Thành công thì đóng bàn phím và chỉ hiển thị xác nhận một lần.
//  Reset hoặc rời màn hình thì hủy thao tác đang chờ.
//  Kiểm tra tap Verify liên tục, mọi kết quả mô phỏng và response đến muộn.

import SwiftUI

struct OTPVerificationStatesScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Verification states")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        OTPVerificationStatesScreen()
    }
}
