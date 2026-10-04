//
//  OTPResendScreen.swift
//  Draft
//
//  Specification — chưa triển khai logic OTP.
//
//  TODO — Mô phỏng gửi lại; cho chỉnh cooldown, expiry, response delay và kết quả gửi.
//  Disable resend khi đang gửi hoặc còn cooldown.
//  Gửi lại thành công: tạo mã và expiry mới, xóa input/lỗi cũ, bắt đầu lại cooldown.
//  Gửi thất bại: giữ mã/expiry hiện tại và cho thử lại.
//  Countdown tính từ deadline; trở lại từ background phải cập nhật đúng thời gian còn lại.
//  Reset hoặc rời màn hình thì hủy thao tác đang chờ; bỏ qua kết quả của phiên cũ.
//  Kiểm tra resend trước/sau cooldown, gửi thất bại và background qua thời điểm hết hạn.
//  Demo controls nằm riêng với form; không gửi SMS thật.

import SwiftUI

struct OTPResendScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Resend & countdown")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        OTPResendScreen()
    }
}
