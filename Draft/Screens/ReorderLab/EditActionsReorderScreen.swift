//
//  EditActionsReorderScreen.swift
//  Draft
//
//  Mục 2 của Reorder a List — `editActions:` và tay nắm luôn hiện.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  editActions: GỌN HƠN onMove, NHƯNG MẤT CÁI MÓC
//  ═══════════════════════════════════════════════════════════════════════════
//
//      ForEach($items, editActions: .move) { $item in … }
//
//  Đưa binding vào là SwiftUI tự sửa mảng, không viết closure, không lo
//  toOffset. Muốn thêm xoá thì đổi thành `.all` (= .move + .delete), vẫn không
//  thêm dòng nào. Đổi lại không còn chỗ chen logic vào lúc dời: muốn chặn,
//  ghi log, lưu xuống đĩa thì quay về onMove (mục 1) hoặc nghe `onChange(of:)`.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  LUÔN HIỆN TAY NẮM
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Tay nắm ☰ chỉ hiện khi editMode = .active. EditButton chẳng qua là cái nút
//  bật/tắt giá trị đó trong môi trường. Không muốn bắt người dùng bấm Edit thì
//  tự cấp editMode cho List — `.environment(\.editMode, $editMode)` — rồi đặt
//  `.active`. Ở đây công tắc "Luôn hiện tay nắm" thay chỗ cho EditButton.
//

import SwiftUI

struct EditActionsReorderScreen: View {
  @State private var items = ReorderItem.samples
  @State private var editMode: EditMode = .inactive
  @State private var allowDelete = false

  var body: some View {
    List {
      Section {
        Toggle("Luôn hiện tay nắm", isOn: alwaysShowHandles)
        Toggle("Cho xoá (editActions: .all)", isOn: $allowDelete)
      }

      Section {
        ForEach($items, editActions: allowDelete ? .all : .move) { $item in
          ReorderItemRow(item: item)
        }
      } footer: {
        Text(verbatim: "items = [\(items.map(\.name).joined(separator: ", "))]")
          .font(.footnote.monospaced())
      }

      Section("Ghi chú") {
        ReorderNote(
          "Không có closure nào",
          "Kéo xong thì dòng items ngay trên tự đổi — SwiftUI ghi thẳng vào mảng qua binding. So với mục 1: không move(fromOffsets:), không toOffset."
        )
        ReorderNote(
          "Thêm xoá chỉ tốn một chữ",
          "Bật \"Cho xoá\" là đổi .move thành .all: hiện thêm nút xoá đỏ khi đang hiện tay nắm, và vuốt trái để xoá."
        )
        ReorderNote(
          "Mất cái móc",
          "Không có chỗ nào báo người dùng vừa dời gì. Cần ghi log hay lưu thì nghe onChange(of: items), hoặc quay về onMove."
        )
      }
    }
    .environment(\.editMode, $editMode)
    .navigationTitle("2 · editActions")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      Button("Khôi phục", systemImage: "arrow.counterclockwise") {
        withAnimation {
          items = ReorderItem.samples
        }
      }
    }
  }

  private var alwaysShowHandles: Binding<Bool> {
    Binding(
      get: { editMode.isEditing },
      set: { editMode = $0 ? .active : .inactive }
    )
  }
}

#Preview {
  NavigationStack {
    EditActionsReorderScreen()
  }
}
