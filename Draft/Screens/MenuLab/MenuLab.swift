//
//  MenuLab.swift
//  Draft
//
//  Menu chọn các thí nghiệm về Menu: subtitle, cấu trúc, chọn lựa.
//

import SwiftUI

struct MenuLab: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Section("Menu của SwiftUI") {
        Button {
          coordinator.push(.menuWithLabeledContent)
        } label: {
          LabRow(title: "LabeledContent - iOS 27",
                 subtitle: "LabeledContent làm label submenu — iOS 18/26/27 vẽ khác nhau")
        }
      }

      Section("Ngăn kéo tự dựng") {
        Button {
          coordinator.push(.sideMenuLab)
        } label: {
          LabRow(title: "Side Menu",
                 subtitle: "Trượt từ cạnh trái — không dùng Menu của SwiftUI")
        }
      }
    }
    .navigationTitle("Menu Lab")
  }
}

// Một dòng trong danh sách: tiêu đề + mô tả ngắn
private struct LabRow: View {
  let title: LocalizedStringKey
  let subtitle: LocalizedStringKey

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title).font(.headline)
      Text(subtitle).font(.caption).foregroundStyle(.secondary)
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  NavigationStack {
    MenuLab()
      .environment(AppCoordinator())
  }
}
