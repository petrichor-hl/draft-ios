//
//  ReorderListLab.swift
//  Draft
//
//  Reorder a List: cho người dùng kéo để đổi thứ tự. Lab đi từ thứ có sẵn
//  đến thứ phải tự dựng — mỗi bước một màn riêng.
//
//  Chọn cách nào gần như chỉ phụ thuộc vào một câu hỏi: có đang dùng `List`
//  không?
//
//      List / Form          → onMove hoặc editActions (mục 1 → 3). Có sẵn
//                             tay nắm, auto-scroll, VoiceOver. Hết.
//      ScrollView / VStack  → không có reorder dựng sẵn, tự viết gesture
//                             (mục 4).
//
//  Section "Reorder a List (2 Ways) - Sean Allen" ở đầu code theo video
//  https://www.youtube.com/watch?v=VNRdRlHsr2k — hai cách editActions và
//  .onMove. Mục 1 → 4 bên dưới là phần lab riêng.
//
//  Dù chọn cách nào, phần quyết định đúng sai vẫn là IDENTITY: ForEach phải
//  lấy id ổn định của dữ liệu, không lấy vị trí. Đổi chỗ chính là lúc vị trí
//  thay đổi — xem Accordion Lab mục 3 để biết vì sao.
//

import SwiftUI

struct ReorderListLab: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Section("Reorder a List (2 Ways) - Sean Allen") {
        Button {
          coordinator.push(.reorderTwoWaysEditActions)
        } label: {
          LabRow(
            title: "editActions",
            subtitle: "ForEach($items, editActions: .move)"
          )
        }

        Button {
          coordinator.push(.reorderTwoWaysOnMove)
        } label: {
          LabRow(
            title: ".onMove",
            subtitle: "ForEach(items) { … }.onMove { … }"
          )
        }
      }

      Section {
        Button {
          coordinator.push(.reorderOnMove)
        } label: {
          LabRow(
            title: "1. onMove + EditButton",
            subtitle: "Cách có sẵn — và cái bẫy của toOffset"
          )
        }

        Button {
          coordinator.push(.reorderEditActions)
        } label: {
          LabRow(
            title: "2. editActions",
            subtitle: "Không cần closure, và tay nắm luôn hiện"
          )
        }

        Button {
          coordinator.push(.reorderLockedRows)
        } label: {
          LabRow(
            title: "3. Hàng bị khoá",
            subtitle: "moveDisabled không phải ghim — ghim thật nằm ở dữ liệu"
          )
        }

        Button {
          coordinator.push(.reorderCustomGesture)
        } label: {
          LabRow(
            title: "4. Tự dựng bằng DragGesture",
            subtitle: "Kéo chỉ đổi offset, thả mới đổi mảng"
          )
        }
      }
    }
    .navigationTitle("Reorder a List")
  }
}

// MARK: - Row

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
    ReorderListLab()
      .environment(AppCoordinator())
  }
}
