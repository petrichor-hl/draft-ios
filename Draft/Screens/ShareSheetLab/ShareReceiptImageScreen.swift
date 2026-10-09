//
//  ShareReceiptImageScreen.swift
//  Draft
//
//  TODO — Tạo receipt card bằng SwiftUI với dữ liệu giao dịch giả.
//  Dùng ImageRenderer render card thành ảnh; chia sẻ ảnh bằng ShareLink.
//  Payload phải là ảnh biên nhận, không chỉ là thumbnail trong SharePreview.
//  Quan sát sheet lúc mới mở và khi kéo lên như hai ảnh tham chiếu.
//  Kiểm tra Copy, Save Image và chất lượng ảnh; action phụ thuộc thiết bị.

import SwiftUI

struct ShareReceiptImageScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Share a receipt image")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ShareReceiptImageScreen()
    }
}
