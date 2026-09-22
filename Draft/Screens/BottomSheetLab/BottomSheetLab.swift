//
//  BottomSheetLab.swift
//  Draft
//
//  Menu các thí nghiệm quanh hai API trình bày modal: sheet (detent cố
//  định, detent co theo content) và fullScreenCover.
//

import SwiftUI

struct BottomSheetLab: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Section(".sheet") {
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

      Section(".fullScreenCover") {
        Button {
          coordinator.push(.fullScreenCover)
        } label: {
          LabRow(title: "1. Cover cơ bản",
                 subtitle: "Phủ hết màn, không có detent hay drag để đóng — tự dựng nút Close")
        }
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
