//
//  LockedRowsReorderScreen.swift
//  Draft
//
//  Mục 3 của Reorder a List — hàng không được kéo, và "ghim ở đầu".
//
//  ═══════════════════════════════════════════════════════════════════════════
//  moveDisabled CHỈ KHOÁ VIỆC NHẤC LÊN
//  ═══════════════════════════════════════════════════════════════════════════
//
//  `.moveDisabled(true)` làm hàng đó không nhấc lên được. Nó KHÔNG giữ hàng
//  đứng yên: hàng khác vẫn thả lên trên nó được, đẩy nó xuống.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  GHIM THẬT LÀ LUẬT CỦA DỮ LIỆU
//  ═══════════════════════════════════════════════════════════════════════════
//
//  "Ghim ở đầu" không phải tính chất của một hàng mà là luật của cả mảng. Bật
//  công tắc để xem cách làm đúng:
//
//    • hàng ghim nằm ở một ForEach KHÔNG có edit action → không có tay nắm,
//      không nhấc được;
//    • phần còn lại đi qua một Binding mà setter luôn dán hàng ghim lên đầu
//      trước khi ghi lại mảng → dù UI có thả đi đâu, thứ tự vẫn đúng luật.
//

import SwiftUI

struct LockedRowsReorderScreen: View {
  @State private var items = ReorderItem.pinnedSamples
  @State private var splitPinned = false

  var body: some View {
    List {
      Section {
        Toggle("Tách hàng ghim ra Section riêng", isOn: $splitPinned)
      }

      if splitPinned {
        Section("Ghim") {
          ForEach(items.filter(\.isPinned)) { item in
            ReorderItemRow(item: item)
          }
        }

        Section {
          ForEach(unpinned, editActions: .move) { $item in
            ReorderItemRow(item: item)
          }
        } header: {
          Text("Còn lại")
        } footer: {
          Text("Thử kéo một hàng lên section Ghim xem có thả vào được không.")
        }
      } else {
        Section {
          ForEach($items, editActions: .move) { $item in
            ReorderItemRow(item: item)
              .moveDisabled(item.isPinned)
          }
        } footer: {
          Text("Bấm Sửa (Edit): Sun và Moon không có tay nắm. Nhưng thử kéo Leaf lên trên Sun xem.")
        }
      }

      Section("Ghi chú") {
        ReorderNote(
          "moveDisabled không phải ghim",
          "Nó chỉ cấm nhấc hàng đó lên. Kéo Leaf lên đầu là Sun và Moon bị đẩy xuống, ghim hay không cũng vậy."
        )
        ReorderNote(
          "Ghim thật nằm ở dữ liệu",
          "Bật công tắc: hàng ghim ở một ForEach không kéo được, phần còn lại đi qua một Binding mà setter luôn dán hàng ghim lên đầu."
        )
      }
    }
    .animation(.default, value: splitPinned)
    .navigationTitle("3 · Hàng bị khoá")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItemGroup(placement: .topBarTrailing) {
        Button("Khôi phục", systemImage: "arrow.counterclockwise") {
          withAnimation {
            items = ReorderItem.pinnedSamples
          }
        }

        EditButton()
      }
    }
  }

  /// Binding vào phần KHÔNG ghim. Setter dán hàng ghim lên đầu rồi mới ghi
  /// lại — luật "ghim luôn ở đầu" nằm ở đây, trong dữ liệu, không ở UI.
  private var unpinned: Binding<[ReorderItem]> {
    Binding(
      get: { items.filter { !$0.isPinned } },
      set: { items = items.filter(\.isPinned) + $0 }
    )
  }
}

#Preview {
  NavigationStack {
    LockedRowsReorderScreen()
  }
}
