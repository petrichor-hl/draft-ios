//
//  CustomGestureReorderScreen.swift
//  Draft
//
//  Mục 4 của Reorder a List — tự dựng bằng `DragGesture`, không nhờ List hay
//  drag & drop.
//
//  Lý do để tự dựng: muốn toàn quyền phần nhìn (hàng nhấc lên phóng to, bóng
//  đổ, cách hàng khác dạt ra), muốn nhấc ngay không phải nhấn giữ, hoặc không
//  muốn ô kéo được sang app khác như drag & drop của hệ thống.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  KÉO CHỈ ĐỔI OFFSET, THẢ MỚI ĐỔI MẢNG
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Trong lúc kéo, mảng đứng yên. Mọi chuyển động là `offset`:
//
//      hàng đang kéo                    offset = quãng ngón tay đã đi
//      hàng nằm giữa chỗ cũ và chỗ đích  offset = ±1 bước (dạt lên / xuống)
//      các hàng khác                    offset = 0
//
//  Lúc thả mới `move` mảng, và trả mọi offset về 0 trong CÙNG một animation.
//  Vị trí layout và offset đổi ngược chiều nhau một lượng bằng nhau, nên các
//  hàng đã dạt đứng yên tại chỗ, còn hàng vừa thả trượt êm vào khe.
//
//  Đổi mảng liên tục trong lúc kéo cũng được, nhưng khi đó layout dời hàng
//  đang kéo đi ngay dưới ngón tay, phải bù offset từng frame. Thêm nữa: dữ liệu chỉ đổi một lần thì lưu, undo, gửi server cũng
//  chỉ một lần.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  ĐO TRONG TOẠ ĐỘ CỦA THỨ ĐỨNG YÊN
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Hàng đang kéo tự dịch theo offset, nên đo translation trong toạ độ của
//  chính nó là đo bằng cây thước đang bị kéo đi. Gesture đo trong coordinate
//  space đặt tên của cái VStack chứa — thứ không nhúc nhích.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  GIÁ PHẢI TRẢ
//  ═══════════════════════════════════════════════════════════════════════════
//
//  • Mọi hàng cao bằng nhau: chỉ số đích = translation / bước. Hàng cao khác
//    nhau thì phải đo từng hàng (onGeometryChange) rồi dò khe.
//  • Không có auto-scroll: danh sách dài hơn màn hình thì phải tự cuộn khi kéo
//    sát mép. List và drag & drop có sẵn cái này.
//  • Không có VoiceOver: phải tự thêm accessibilityAction để dời lên / xuống.
//

import SwiftUI

struct CustomGestureReorderScreen: View {
  @State private var items = ReorderItem.samples
  @State private var drag: DragState?
  /// Hàng vừa thả vẫn cần nằm trên cùng trong lúc trượt về khe, nên không
  /// lấy `drag` (đã nil) để quyết zIndex.
  @State private var lastDraggedID: ReorderItem.ID?

  private let rowHeight: CGFloat = 56
  private let spacing: CGFloat = 8
  private var step: CGFloat { rowHeight + spacing }

  private static let space = "customReorder"

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        Text("Kéo tay nắm ☰ — nhấc ngay, không cần nhấn giữ.")
          .font(.footnote)
          .foregroundStyle(.secondary)

        list

        Text(verbatim: "items = [\(items.map(\.name).joined(separator: ", "))]")
          .font(.footnote.monospaced())
          .foregroundStyle(.secondary)

        notes
      }
      .padding(20)
    }
    .scrollDisabled(drag != nil)
    .background(Color(.systemGroupedBackground))
    .navigationTitle("4 · DragGesture")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      Button("Khôi phục", systemImage: "arrow.counterclockwise") {
        withAnimation(.snappy) {
          items = ReorderItem.samples
        }
      }
    }
  }

  // MARK: Danh sách

  private var list: some View {
    VStack(spacing: spacing) {
      // id lấy theo dữ liệu chứ không theo vị trí — xem Accordion Lab mục 3.
      // `Array(...)` vì conformance RandomAccessCollection của
      // EnumeratedSequence chỉ có từ iOS 26.
      ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
        let isDragged = item.id == drag?.id
        let offset = offset(at: index, id: item.id)

        HStack {
          ReorderItemRow(item: item)

          Spacer()

          Image(systemName: "line.3.horizontal")
            .foregroundStyle(.secondary)
            .frame(width: 44, height: rowHeight)
            .contentShape(.rect)
            .gesture(reorderGesture(for: item, at: index))
        }
        .padding(.leading, 12)
        .frame(height: rowHeight)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
        .scaleEffect(isDragged ? 1.03 : 1)
        .shadow(color: .black.opacity(isDragged ? 0.15 : 0), radius: 10, y: 4)
        .animation(.snappy, value: isDragged)
        .offset(y: offset)
        // Hàng đang kéo phải bám ngón tay từng frame — không animate.
        // Các hàng khác thì có: lúc chúng dạt ra nhường chỗ.
        .animation(isDragged ? nil : .snappy, value: offset)
        .zIndex(item.id == lastDraggedID ? 1 : 0)
      }
    }
    .coordinateSpace(.named(Self.space))
    .sensoryFeedback(.selection, trigger: drag.map(target(of:)))
  }

  // MARK: Gesture

  private func reorderGesture(for item: ReorderItem, at index: Int) -> some Gesture {
    DragGesture(minimumDistance: 0, coordinateSpace: .named(Self.space))
      .onChanged { value in
        if drag == nil {
          drag = DragState(id: item.id, from: index, translation: 0)
          lastDraggedID = item.id
        }
        drag?.translation = value.translation.height
      }
      .onEnded { _ in
        guard let drag else { return }
        let to = target(of: drag)

        // Một animation cho cả hai: mảng đổi (layout dời) và offset về 0.
        withAnimation(.snappy) {
          if to != drag.from {
            items.move(
              fromOffsets: IndexSet(integer: drag.from),
              toOffset: to > drag.from ? to + 1 : to
            )
          }
          self.drag = nil
        }
      }
  }

  /// Khe mà hàng đang kéo sẽ rơi vào nếu thả ngay bây giờ.
  private func target(of drag: DragState) -> Int {
    let raw = drag.from + Int((drag.translation / step).rounded())
    return min(max(raw, 0), items.count - 1)
  }

  private func offset(at index: Int, id: ReorderItem.ID) -> CGFloat {
    guard let drag else { return 0 }
    if id == drag.id { return drag.translation }

    let to = target(of: drag)
    if drag.from < to, (drag.from + 1)...to ~= index { return -step }
    if drag.from > to, to..<drag.from ~= index { return step }
    return 0
  }

  // MARK: Ghi chú

  private var notes: some View {
    VStack(alignment: .leading, spacing: 12) {
      ReorderNote(
        "Nhìn dòng items = […]",
        "Kéo chậm qua vài hàng: các hàng dạt ra nhưng dòng items không đổi. Chỉ lúc thả nó mới đổi — đúng một lần."
      )
      ReorderNote(
        "Vì sao chỉ nắm ở tay nắm",
        "DragGesture gắn cả hàng thì vuốt dọc trên hàng sẽ là kéo, ScrollView không cuộn được nữa. Muốn nắm cả hàng thì ghép LongPressGesture().sequenced(before: DragGesture()) — vuốt nhanh là cuộn, giữ rồi mới kéo."
      )
      ReorderNote(
        "Chưa làm",
        "Auto-scroll khi kéo sát mép, hàng cao khác nhau, và VoiceOver. Đó là phần List cho không, và là lý do nên dùng List nếu được."
      )
    }
  }
}

private struct DragState {
  let id: ReorderItem.ID
  /// Vị trí trong mảng lúc nhấc lên. Mảng không đổi trong lúc kéo nên số này
  /// đúng tới tận lúc thả.
  let from: Int
  var translation: CGFloat
}

#Preview {
  NavigationStack {
    CustomGestureReorderScreen()
  }
}
