//
//  ShareUIKitControlsScreen.swift
//  Draft
//
//  TODO — Bọc UIActivityViewController để dùng từ SwiftUI.
//  Truyền activityItems; thử excludedActivityTypes để ẩn action phù hợp.
//  Dùng completionWithItemsHandler để hiển thị completed, cancelled hoặc error.
//  Completed là kết quả activity báo về, không bảo đảm người nhận đã nhận nội dung.
//  Kiểm tra dismiss và mở lại; cấu hình popover anchor nếu present trực tiếp trên iPad.
//  Contact gợi ý và thứ tự app do hệ thống quản lý, không tự dựng theo screenshot.

import SwiftUI

struct ShareUIKitControlsScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("UIKit controls")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ShareUIKitControlsScreen()
    }
}
