//
//  ShareSheetLab.swift
//  Draft
//
//  Lab chia sẻ nội dung qua share sheet hệ thống; mỗi bài có màn hình riêng.
//  Các screen hiện là placeholder; hướng triển khai nằm trong comment mỗi file.

import SwiftUI

struct ShareSheetLab: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        List {
            Section("SwiftUI — ShareLink") {
                labLink("1. Share a link",
                        subtitle: "Chia sẻ URL bằng ShareLink, thêm tiêu đề và preview",
                        route: .shareLink)
                labLink("2. Share text",
                        subtitle: "Chia sẻ chuỗi văn bản, so sánh action với URL",
                        route: .shareText)
                labLink("3. Share a receipt image",
                        subtitle: "Render biên nhận thành ảnh, chia sẻ như ảnh tham chiếu",
                        route: .shareReceiptImage)
            }

            Section("UIKit — UIActivityViewController") {
                labLink("4. UIKit controls",
                        subtitle: "Loại trừ activity, theo dõi hoàn tất hoặc hủy chia sẻ",
                        route: .shareUIKitControls)
            }
        }
        .navigationTitle("Share Sheet Lab")
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
        ShareSheetLab()
            .environment(AppCoordinator())
    }
}
