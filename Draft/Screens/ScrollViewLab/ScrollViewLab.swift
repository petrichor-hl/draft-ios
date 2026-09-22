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

      Button {
        coordinator.push(.scrollViewFixedHeight)
      } label: {
        LabRow(title: "4. Fixed 400pt",
               subtitle: "Khung luôn cao 400 — content ngắn thì dư chỗ trống")
      }

      Button {
        coordinator.push(.scrollViewCappedHeight)
      } label: {
        LabRow(title: "5. Cap 400pt",
               subtitle: "Khung co theo content, chặn trên ở 400")
      }

      Button {
        coordinator.push(.scrollViewMaxHeight)
      } label: {
        LabRow(title: "6. maxHeight 400pt",
               subtitle: "Khung vẫn 400pt dù content chỉ 60pt — không co theo content")
      }

      Button {
        coordinator.push(.scrollViewMaxHeightInSheet)
      } label: {
        LabRow(title: "7. maxHeight trong sheet",
               subtitle: "Bàn phím co sheet, khung tụt xuống dưới 400")
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
