//
//  FormLab.swift
//  Draft
//

import SwiftUI

struct FormLab: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        List {
            Section("Input") {
                labLink("1. Password visibility",
                        subtitle: "Ẩn mặc định, eye button bật/tắt hiển thị",
                        route: .formPassword)
                labLink("2. Leading icon",
                        subtitle: "Icon đầu ô nhập, căn chỉnh với nội dung",
                        route: .formLeadingIcon)
                labLink("3. Numeric input",
                        subtitle: "Chỉ nhận số — kiểm tra cả gõ và paste",
                        route: .formNumericInput)
                labLink("4. Autofill",
                        subtitle: "Username, password, mã OTP và cấu hình ô nhập",
                        route: .formAutofill)
            }

            Section("Keyboard & Focus") {
                labLink("5. Keyboard avoidance",
                        subtitle: "Ô nhập gần đáy vẫn nhìn thấy khi bàn phím mở",
                        route: .formKeyboardAvoidance)
                labLink("6. Initial focus",
                        subtitle: "Tự focus ô đầu tiên khi vào màn hình",
                        route: .formInitialFocus)
                labLink("7. Next / Done",
                        subtitle: "Chuyển focus, cuộn tới ô tiếp theo, kết thúc nhập",
                        route: .formNextFocus)
                labLink("8. Focused border",
                        subtitle: "Đổi màu viền theo focus và trạng thái lỗi",
                        route: .formFocusedBorder)
            }

            Section("Validation & Submit") {
                labLink("9. Validation",
                        subtitle: "Bắt buộc, định dạng, xác nhận mật khẩu — lỗi từng ô",
                        route: .formValidation)
                labLink("10. Submission",
                        subtitle: "Loading, chặn gửi lặp, lỗi server và thử lại",
                        route: .formSubmission)
            }
        }
        .navigationTitle("Form Lab")
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
        FormLab()
            .environment(AppCoordinator())
    }
}
