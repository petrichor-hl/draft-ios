//
//  MultiExpandAccordionScreen.swift
//  Draft
//
//  Mục 3 của Accordion Lab — cụm MỞ TỰ DO (multi-expand).
//
//  Tiếng Anh gọi là multi-expand / multiple open; Bootstrap đặt tên mục này là
//  "Always open", Radix là `type="multiple"`, Angular Material là `multi`.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  VÌ SAO MỤC NÀY GẦN NHƯ KHÔNG CÓ CODE
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Vì mỗi row đã tự giữ state của nó rồi. Xếp mấy cái đơn lẻ vào một `VStack`
//  là xong — không có "logic của cụm" nào cả, cụm chỉ là cái vỏ.
//
//  Nói cách khác: mục này KHÔNG phải accordion theo nghĩa hẹp. Các row không
//  biết nhau, không ảnh hưởng nhau. Đúng tên phải là một chồng disclosure.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  NHƯNG ĐỔI LẠI: STATE NẰM TRONG ROW THÌ NÓ DÍNH VÀO IDENTITY CỦA ROW
//  ═══════════════════════════════════════════════════════════════════════════
//
//  `@State` không thuộc về dữ liệu, nó thuộc về CHỖ ĐỨNG của view trong cây.
//  SwiftUI nhận ra "vẫn là view cũ" bằng identity — trong `ForEach` chính là
//  cái `id` bạn đưa cho nó.
//
//      ForEach(panels)                      → id là panel.id     (đúng)
//      ForEach(Array(...enumerated()), id: \.offset) → id là VỊ TRÍ  (sai)
//
//  Lấy vị trí làm id thì xoá một phần tử ở đầu sẽ làm mọi phần tử sau tụt lên
//  một bậc. Với SwiftUI, "view ở vị trí 0" vẫn là view cũ — nội dung đổi
//  nhưng `@State` giữ nguyên. Kết quả: trạng thái mở/đóng dính theo VỊ TRÍ chứ
//  không theo nội dung. Bấm thử công tắc bên dưới để thấy tận mắt.
//
//  Bẫy này không lộ ra khi danh sách đứng yên. Nó chỉ xuất hiện lúc xoá, chèn
//  hay sắp xếp lại — nghĩa là muộn, và ở đúng chỗ khó lần nhất.
//
//  Đã kiểm trên iPhone 16 Pro (iOS 18.6), danh sách #1 #2 #3, mở #2 rồi xoá
//  mục đầu:
//
//      id: \.offset   còn lại #2 #3, cái đang mở là #3   ← state ở lại vị trí
//      id: panel.id   còn lại #2 #3, cái đang mở là #2   ← state theo dữ liệu
//

import SwiftUI

struct MultiExpandAccordionScreen: View {
  @State private var panels = Panel.samples
  @State private var identity: IdentityMode = .stableID

  /// Đổi giá trị này là ép SwiftUI dựng lại cả cụm — xem `closeAll()`.
  @State private var resetToken = UUID()

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        Text(
          """
          Mở vài mục cùng lúc — không mục nào đóng mục nào, vì mỗi row tự giữ \
          state riêng. Phần đáng học nằm ở hai nút bên dưới.
          """
        )
        .font(.footnote)
        .foregroundStyle(.secondary)

        card

        controls

        notes
      }
      .padding(20)
    }
    .navigationTitle("3 · Multi-expand")
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: Cụm

  private var card: some View {
    AccordionCard {
      switch identity {
      case .stableID:
        // `Panel` là Identifiable → ForEach tự lấy `panel.id`.
        ForEach(panels) { panel in
          if panel.id != panels.first?.id { Divider() }

          SelfManagedAccordionRow(title: panel.title, content: panel.detail)
        }

      case .position:
        // Cố tình sai: id là vị trí trong mảng.
        //
        // `panels.enumerated()` cho một EnumeratedSequence, phần tử là tuple
        // có nhãn `(offset: Int, element: Panel)`. Phải chỉ `id:` vì tuple
        // không conform được protocol nào, kể cả Identifiable.
        //
        // Vì sao phải bọc `Array(...)`: ForEach đòi RandomAccessCollection.
        // EnumeratedSequence CÓ conform, nhưng conformance đó chỉ có từ
        // iOS 26.0 — repo này deploy iOS 18.6 nên bỏ Array ra là dính
        // "conformance ... is only available in iOS 26.0 or newer; this is an
        // error in the Swift 6 language mode" (24 warning một lần build).
        // Bọc Array là tính sẵn ra một mảng thật, không nhờ conformance nào.
        //
        // Gọi là `offset` chứ không phải `index`: với ArraySlice (sau
        // dropFirst chẳng hạn) offset đếm lại từ 0 trong khi index thật vẫn
        // bắt đầu từ 1 — lấy offset đi truy cập mảng là sai phần tử.
        ForEach(Array(panels.enumerated()), id: \.offset) { offset, panel in
          if offset != 0 { Divider() }

          SelfManagedAccordionRow(title: panel.title, content: panel.detail)
        }
      }
    }
    .id(resetToken)
  }

  // MARK: Công tắc

  private var controls: some View {
    VStack(alignment: .leading, spacing: 16) {
      VStack(alignment: .leading, spacing: 8) {
        Text("identity của ForEach")
          .font(.subheadline)

        Picker("identity", selection: $identity) {
          ForEach(IdentityMode.allCases) { mode in
            Text(mode.label).tag(mode)
          }
        }
        .pickerStyle(.segmented)
      }

      HStack(spacing: 12) {
        Button("Xoá mục đầu") {
          withAnimation(.snappy) {
            if !panels.isEmpty { panels.removeFirst() }
          }
        }
        .disabled(panels.isEmpty)

        Button("Khôi phục") {
          withAnimation(.snappy) {
            panels = Panel.samples
          }
        }
        .disabled(panels.count == Panel.samples.count)
      }
      .buttonStyle(.bordered)

      Button("Đóng tất cả", systemImage: "arrow.up.to.line") {
        /// Cha KHÔNG với tới được `isExpanded` của từng row, nên không thể đóng
        /// từng cái một cách đàng hoàng. Cách duy nhất còn lại là đổi identity của
        /// cả cụm để SwiftUI vứt cây cũ đi và dựng lại từ đầu — `@State` mới sinh ra
        /// nên trở về `false`.
        ///
        /// Giá phải trả: không animate được (đây là THAY view chứ không phải đổi
        /// giá trị), mọi state khác trong cụm cũng mất, `onAppear` chạy lại. Dùng
        /// được nhưng là dấu hiệu state đang nằm sai chỗ — mục 4 làm đúng cách.
        resetToken = UUID()
      }
      .buttonStyle(.bordered)
    }
    .font(.subheadline)
  }

  // MARK: Ghi chú

  private var notes: some View {
    VStack(alignment: .leading, spacing: 12) {
      Note(
        "Thử cái bẫy",
        "Theo ĐÚNG thứ tự: chọn identity = vị trí TRƯỚC, rồi mở mục #2, rồi bấm Xoá mục đầu. Cái đang mở hoá ra là #3 — trạng thái mở ở lại VỊ TRÍ cũ, còn nội dung đã tụt lên một bậc."
      )
      Note(
        "Chọn theo id thì sao",
        "Cũng mở #2 rồi xoá mục đầu, nhưng lần này #2 vẫn mở. Identity đi theo dữ liệu nên @State bám đúng row của nó."
      )
      Note(
        "Vì sao phải chọn identity trước",
        "Vì gạt cái Picker cũng làm mất trạng thái mở: hai nhánh của switch là hai cây view khác nhau, nên @State bị dựng lại từ đầu. Cùng một nguyên nhân với cái bẫy ở trên."
      )
      Note(
        "Đóng tất cả bị giật",
        "Vì nó không đóng gì cả — nó vứt cả cụm đi dựng lại. Đây là dấu hiệu state nằm sai chỗ, và là lý do mục 4 tồn tại."
      )
    }
  }

  private func Note(_ title: LocalizedStringKey, _ body: LocalizedStringKey) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title).font(.caption.weight(.semibold))
      Text(body).font(.caption).foregroundStyle(.secondary)
    }
  }
}

// MARK: - Dữ liệu

struct Panel: Identifiable {
  let id = UUID()
  let title: String
  let detail: String

  /// Ba body dài NGẮN KHÁC HẲN NHAU, có chủ đích: chiều cao đích mỗi lần mở
  /// một khác nên nhìn rõ được animation đang chạy trên chiều cao thật, không
  /// phải một con số cố định. Ở mục 4 còn rõ hơn — mở cái ngắn sau khi đang mở
  /// cái dài thì cả cụm co lại, chứ không chỉ trượt.
  static let samples = [
    Panel(
      title: "Accordion Item #1",
      detail: "This one is short."
    ),
    Panel(
      title: "Accordion Item #2",
      detail: """
        This is the second item's accordion body. It is hidden by default, \
        until the collapse plugin adds the appropriate classes.
        """
    ),
    Panel(
      title: "Accordion Item #3",
      detail: """
        This is the third item's accordion body, and it is deliberately the \
        long one. It is hidden by default, until the collapse plugin adds the \
        appropriate classes that we use to style each element.

        These classes control the overall appearance, as well as the showing \
        and hiding via CSS transitions. You can modify any of this with custom \
        CSS or overriding the default variables.

        It's also worth noting that just about any HTML can go within the \
        accordion body, though the transition does limit overflow.
        """
    )
  ]
}

private enum IdentityMode: String, CaseIterable, Identifiable {
  case stableID, position

  var id: String { rawValue }

  var label: String {
    switch self {
    case .stableID: return "\\.id — đúng"
    case .position: return "vị trí — sai"
    }
  }
}

#Preview {
  NavigationStack {
    MultiExpandAccordionScreen()
  }
}
