//
//  KeyboardLab.swift
//  Draft
//
//  Menu chọn cách xử lý keyboard để so sánh cảm giác trực tiếp.
//

import SwiftUI

struct KeyboardLab: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Button {
        coordinator.push(.keyboardBaseline)
      } label: {
        LabRow(title: "Baseline",
               subtitle: "safeAreaInset — thanh nhập desync khi kéo")
      }

      Button {
        coordinator.push(.keyboardTracking)
      } label: {
        LabRow(title: "Tracking",
               subtitle: "Tự đọc chiều cao bàn phím (SwiftUI)")
      }

      Button {
        coordinator.push(.keyboardAccessory)
      } label: {
        LabRow(title: "Accessory",
               subtitle: "inputAccessoryView (UIKit) — dính keo")
      }

      Button {
        coordinator.push(.keyboardLayoutGuide)
      } label: {
        LabRow(title: "Layout Guide ⭐️",
               subtitle: "keyboardLayoutGuide — bar rời, dừng êm - Giống Zalo")
      }
    }
    .navigationTitle("Keyboard Lab")
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
    KeyboardLab()
      .environment(AppCoordinator())
  }
}
