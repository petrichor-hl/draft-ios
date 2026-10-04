//
//  OTPCompleteFlowScreen.swift
//  Draft
//
//  Specification — chưa triển khai logic OTP.
//
//  TODO — Flow đầy đủ với destination giả được che một phần và mã 6 chữ số.
//  Kết hợp input, autofill, nút Verify, loading, lỗi inline, resend và success.
//  Chặn gửi lặp; giữ mã khi lỗi tạm thời; hỗ trợ sửa mã hoặc gửi lại khi cần.
//  Change destination tạo phiên mới; kết quả phiên cũ không được cập nhật phiên mới.
//  Reset demo khôi phục trạng thái đầu và hủy thao tác đang chờ; rời màn hình cũng hủy.
//  Tách demo controls: kết quả verify/resend, response delay, cooldown và expiry.
//  Dùng deadline cho countdown để xử lý background đúng.
//  Kiểm tra mã bắt đầu bằng 0, paste, lỗi, resend, stale response và thành công một lần.
//  Kiểm tra VoiceOver, chữ lớn, màn hình nhỏ và bàn phím ngoài.
//  Verify và resend được mô phỏng cục bộ; chưa tích hợp server hoặc SMS thật.

import SwiftUI

struct OTPCompleteFlowScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Complete flow")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        OTPCompleteFlowScreen()
    }
}
