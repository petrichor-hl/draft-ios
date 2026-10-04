//
//  OnMoveReorderScreen.swift
//  Draft
//
//  Mục 1 của Reorder a List — `ForEach.onMove`, cách có sẵn và lâu đời nhất.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  onMove CHỈ CÓ TÁC DỤNG TRONG List
//  ═══════════════════════════════════════════════════════════════════════════
//
//  `.onMove` gắn vào `ForEach`, nhưng chỉ có tác dụng khi ForEach đó nằm trong
//  `List` (hoặc `Form`). Đặt trong `VStack` hay `LazyVStack` thì không lỗi,
//  không cảnh báo — chỉ là không có gì xảy ra. Ngoài List phải tự làm, xem
//  mục 4.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  toOffset KHÔNG PHẢI VỊ TRÍ ĐÍCH
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Closure nhận `(IndexSet, Int)`. Số thứ hai là KHE để chèn, đếm trên mảng
//  TRƯỚC khi rút phần tử ra — như con trỏ văn bản đứng giữa hai dòng:
//
//      [A, B, C, D]   kéo A xuống dưới C
//      toOffset = 3   (khe giữa C và D, đếm lúc A vẫn còn ở đầu)
//      kết quả        [B, C, A, D]  → A ở index 2, không phải 3
//
//  Kéo LÊN thì toOffset trùng index cuối, kéo XUỐNG thì lệch 1. Vì thế đừng tự
//  viết `remove(at:)` + `insert(_:at:)` — dùng `move(fromOffsets:toOffset:)`
//  của SwiftUI, nó hiểu đúng quy ước này. Picker trên màn hình cho xem bản tự
//  viết sai thế nào.
//
//  Tham số đầu là IndexSet chứ không phải Int để chừa chỗ cho việc dời nhiều
//  phần tử một lúc. Bản tự viết lấy `source.first` là đã bỏ qua trường hợp đó.
//

import SwiftUI

struct OnMoveReorderScreen: View {
  @State private var items = ReorderItem.samples
  @State private var strategy: MoveStrategy = .swiftUI
  @State private var log: [MoveLogEntry] = []

  var body: some View {
    List {
      Section {
        Picker("Cài đặt move", selection: $strategy) {
          ForEach(MoveStrategy.allCases) { strategy in
            Text(strategy.label).tag(strategy)
          }
        }
        .pickerStyle(.segmented)
      } footer: {
        Text("Chọn \"tự viết\" rồi kéo một hàng XUỐNG — nó rơi thấp hơn chỗ thả một hàng.")
      }

      Section {
        ForEach(items) { item in
          ReorderItemRow(item: item)
        }
        .onMove(perform: move)
        .onDelete { items.remove(atOffsets: $0) }
      } footer: {
        Text("Nhấn giữ một hàng rồi kéo, hoặc bấm Edit để hiện tay nắm.")
      }

      Section("Nhật ký onMove") {
        if log.isEmpty {
          Text("Chưa kéo lần nào.")
            .foregroundStyle(.secondary)
        }

        ForEach(log) { entry in
          MoveLogRow(entry: entry)
        }
      }

      Section("Ghi chú") {
        ReorderNote(
          "Không cần Edit vẫn kéo được",
          "Từ iOS 16, List có onMove cho nhấn giữ rồi kéo ngay. EditButton chỉ để hiện tay nắm — dễ thấy hơn, và là đường duy nhất với VoiceOver."
        )
        ReorderNote(
          "toOffset đếm trên mảng cũ",
          "Xem cột toOffset trong nhật ký: kéo xuống thì nó luôn lớn hơn index thật 1 đơn vị, kéo lên thì bằng."
        )
        ReorderNote(
          "Bản tự viết còn crash",
          "Kéo xuống đáy thì toOffset = số phần tử cũ, sau khi remove thì lớn hơn count 1 → insert(at:) văng. Code ở đây phải min() để khỏi crash."
        )
      }
    }
    .navigationTitle("1 · onMove")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItemGroup(placement: .topBarTrailing) {
        Button("Khôi phục", systemImage: "arrow.counterclockwise") {
          withAnimation {
            items = ReorderItem.samples
            log = []
          }
        }

        EditButton()
      }
    }
  }

  private func move(from source: IndexSet, to destination: Int) {
    guard let first = source.first else { return }
    let moved = items[first]

    switch strategy {
    case .swiftUI:
      items.move(fromOffsets: source, toOffset: destination)

    case .naive:
      // Cách hay gặp: rút ra rồi chèn vào đúng toOffset. Sai khi kéo xuống —
      // rút xong thì mọi phần tử phía sau đã tụt lên 1, nên chèn ở toOffset là
      // rơi thấp hơn chỗ thả một hàng. `min` chỉ để kéo xuống đáy không crash.
      let item = items.remove(at: first)
      items.insert(item, at: min(destination, items.count))
    }

    let entry = MoveLogEntry(
      name: moved.name,
      source: Array(source),
      destination: destination,
      expected: destination > first ? destination - 1 : destination,
      landed: items.firstIndex { $0.id == moved.id } ?? destination
    )
    log.insert(entry, at: 0)
    log = Array(log.prefix(6))
  }
}

// MARK: - Nhật ký

private struct MoveLogEntry: Identifiable {
  let id = UUID()
  let name: String
  let source: [Int]
  let destination: Int
  /// Chỗ người dùng thả — index mà phần tử LẼ RA phải nằm.
  let expected: Int
  /// Chỗ phần tử thật sự nằm sau khi sửa mảng.
  let landed: Int
}

private struct MoveLogRow: View {
  let entry: MoveLogEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(verbatim: "\(entry.name) · fromOffsets \(entry.source) · toOffset \(entry.destination)")
        .font(.footnote.monospaced())

      if entry.landed == entry.expected {
        Label("Nằm ở index \(entry.landed)", systemImage: "checkmark.circle.fill")
          .font(.caption)
          .foregroundStyle(.green)
      } else {
        Label(
          "Nằm ở index \(entry.landed), lẽ ra là \(entry.expected)",
          systemImage: "xmark.circle.fill"
        )
        .font(.caption)
        .foregroundStyle(.red)
      }
    }
  }
}

private enum MoveStrategy: String, CaseIterable, Identifiable {
  case swiftUI, naive

  var id: String { rawValue }

  var label: String {
    switch self {
    case .swiftUI: return "move(fromOffsets:)"
    case .naive: return "remove + insert"
    }
  }
}

#Preview {
  NavigationStack {
    OnMoveReorderScreen()
  }
}
