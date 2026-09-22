//
//  ScrollViewLab.swift
//  Draft
//
//  Menu các thí nghiệm quanh ScrollView: nội dung tràn safe area,
//  chừa lề bằng contentMargins, và swipe actions tự làm.
//

import SwiftUI

struct ScrollViewLab: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Button {
        coordinator.push(.scrollViewSafeArea)
      } label: {
        LabRow(title: "1. Safe Area",
               subtitle: "mask() chặn item tràn vào top & bottom safe area")
      }

      Button {
        coordinator.push(.scrollViewContentMargins)
      } label: {
        LabRow(title: "2. contentMargins",
               subtitle: "Chỉnh edges & placement để thấy lề tác động lên content vs indicator")
      }

      Button {
        coordinator.push(.scrollViewSwipeActions)
      } label: {
        LabRow(title: "3. Swipe Actions (Kavsoft)",
               subtitle: "ScrollView không có swipeActions như List — tự dựng lại")
      }
    }
    .navigationTitle("ScrollView Lab")
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
    ScrollViewLab()
      .environment(AppCoordinator())
  }
}
