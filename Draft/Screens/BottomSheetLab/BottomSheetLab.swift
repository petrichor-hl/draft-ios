//
//  BottomSheetLab.swift
//  Draft
//
//  Menu các thí nghiệm quanh bottom sheet: detent cố định, và detent
//  co theo chiều cao content ở hai thế hệ API đo kích thước.
//

import SwiftUI

struct BottomSheetLab: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Button {
        coordinator.push(.fixedHeightBottomSheet)
      } label: {
        LabRow(title: "1. Fixed Height",
               subtitle: "presentationDetents([.height(600)]) — sheet luôn cao 600")
      }

      Button {
        coordinator.push(.dynamicHeightBottomSheet)
      } label: {
        LabRow(title: "2. Dynamic Height (iOS 16+)",
               subtitle: "Đo content bằng GeometryReader trong background rồi đẩy vào detent")
      }

      Button {
        coordinator.push(.dynamicHeightBottomSheetiOS18)
      } label: {
        LabRow(title: "3. Dynamic Height (iOS 18+)",
               subtitle: "Cùng kết quả nhưng đo bằng onGeometryChange, không cần view phụ")
      }
    }
    .navigationTitle("Bottom Sheet Lab")
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
    BottomSheetLab()
      .environment(AppCoordinator())
  }
}
