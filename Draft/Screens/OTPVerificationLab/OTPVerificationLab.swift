//
//  OTPVerificationLab.swift
//  Draft
//
//  Specification — Lab nhập và xác minh mã OTP, mỗi bài có màn hình riêng.
//  Mặc định mã 6 chữ số và destination giả được che một phần.
//  Các bài có so sánh độ dài cho chọn mã 4 hoặc 6; luôn giữ số 0 đầu.
//  Demo controls nằm riêng với form; Verify và resend mô phỏng cục bộ.
//  Reset hoặc rời bài tập phải hủy thao tác đang chờ và bỏ qua kết quả cũ.
//  Autofill hệ thống cần được quan sát riêng trên thiết bị thật.
//  Các screen hiện là placeholder; specification nằm trong comment mỗi file.

import SwiftUI

struct OTPVerificationLab: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        List {
            Section("Input") {
                labLink("1. Single field",
                        subtitle: "Một ô nhập mã, giữ số 0 đầu và giới hạn độ dài",
                        route: .otpSingleField)
                labLink("2. Segmented appearance",
                        subtitle: "Một ô nhập, hiển thị mã thành các ô riêng",
                        route: .otpSegmentedAppearance)
                labLink("3. Separate fields",
                        subtitle: "Mỗi chữ số một ô, chuyển focus và xử lý backspace",
                        route: .otpSeparateFields)
                labLink("4. Paste & replacement",
                        subtitle: "Dán cả mã, thay vùng chọn, xử lý dữ liệu không hợp lệ",
                        route: .otpPaste)
                labLink("5. Autofill",
                        subtitle: "Nhận mã từ gợi ý hệ thống, kiểm tra trên thiết bị",
                        route: .otpAutofill)
            }

            Section("Keyboard & Focus") {
                labLink("6. Focus & keyboard",
                        subtitle: "Focus khi vào màn hình, mở lại bàn phím, nút Xong",
                        route: .otpFocus)
            }

            Section("Verification & Recovery") {
                labLink("7. Verification states",
                        subtitle: "Thiếu mã, đang xác minh, sai mã, hết hạn và thành công",
                        route: .otpVerificationStates)
                labLink("8. Resend & countdown",
                        subtitle: "Gửi lại mã, đếm ngược và thử lại khi gửi thất bại",
                        route: .otpResend)
                labLink("9. Complete flow",
                        subtitle: "Nhập mã → xác minh → sửa lỗi hoặc gửi lại → thành công",
                        route: .otpCompleteFlow)
            }
        }
        .navigationTitle("OTP — Verification Code Lab")
    }

    private func labLink(_ title: LocalizedStringKey, subtitle: LocalizedStringKey, route: AppRoute) -> some View {
        Button {
            coordinator.push(route)
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    NavigationStack {
        OTPVerificationLab()
            .environment(AppCoordinator())
    }
}
