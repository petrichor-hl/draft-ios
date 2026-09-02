//
//  SingleOpenAccordionScreen.swift
//  Draft
//
//  Mục 4 của Accordion Lab — cụm SINGLE-OPEN (exclusive accordion).
//
//  Bootstrap làm bằng `data-bs-parent`, Radix là `type="single"`. Đây mới là
//  accordion theo nghĩa hẹp: mở ngăn này thì ngăn kia xẹp xuống.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  KHÔNG PHẢI "ĐÓNG CÁI KIA ĐI" — MÀ LÀ KHÔNG CÓ CHỖ ĐỂ CHỨA HAI CÁI MỞ
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Cách nghĩ sai (và là cách ai cũng nghĩ trước tiên): giữ nguyên mỗi row một
//  `Bool`, khi row A mở thì đi bảo mấy row kia đóng lại. Làm vậy phải cho các
//  row nói chuyện với nhau, và lúc nào cũng có nguy cơ hai row cùng `true` do
//  sót một nhánh.
//
//  Cách đúng: cả cụm chỉ có MỘT biến, và biến đó chỉ chứa được một giá trị.
//
//      mục 3   mỗi row một Bool           → 2^n trạng thái, mọi tổ hợp đều mở được
//      mục 4   cha giữ một Panel.ID?      → n+1 trạng thái, hai cái cùng mở là
//                                            KHÔNG BIỂU DIỄN ĐƯỢC
//
//  Không có dòng code nào đi "đóng row kia" cả. Row kia đóng vì `expandedID`
//  không còn trỏ vào nó nữa — sai không xảy ra được, chứ không phải sai bị bắt.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  HỆ QUẢ: ROW PHẢI LÀ BẢN CONTROLLED
//  ═══════════════════════════════════════════════════════════════════════════
//
//      mục 3   SelfManagedAccordionRow   tự giữ @State
//      mục 4   AccordionRow              nhận `isExpanded` vào, bấm thì `onTap`
//
//  Nếu row vẫn tự giữ state thì cha không đọc được nó, cũng không ghi được —
//  đúng bế tắc của nút "Đóng tất cả" ở mục 3, chỗ phải dùng `.id(UUID())` để
//  vứt cả cụm đi dựng lại. Ở đây "đóng tất cả" chỉ là `expandedID = nil`.
//

import SwiftUI

struct SingleOpenAccordionScreen: View {
  @State private var expandedID: Panel.ID? = nil

  private let panels = Panel.samples

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        Text(
          """
          Mở một mục thì mục đang mở tự xẹp. Không có dòng code nào đi đóng nó \
          — nó đóng vì `expandedID` không còn trỏ vào nó nữa.
          """
        )
        .font(.footnote)
        .foregroundStyle(.secondary)

        SubTitle("Tự dựng — AccordionRow bản controlled")

        AccordionCard {
          ForEach(panels) { panel in
            if panel.id != panels.first?.id { Divider() }

            AccordionRow(
              title: panel.title,
              content: panel.detail,
              // Row không nhớ gì. Mở hay không là do so sánh với biến của cha.
              isExpanded: expandedID == panel.id
            ) {
              toggle(panel)
            }
          }
        }

        controls

        Divider()

        SubTitle("Cùng hành vi, nhưng bằng DisclosureGroup có sẵn")

        builtInVersion

        notes
      }
      .padding(20)
    }
    .navigationTitle("4 · Single-open")
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: Logic

  /// Cả cụm gói gọn trong hàm này.
  private func toggle(_ panel: Panel) {
    // Một `withAnimation` cho cả hai chuyển động: cái đang mở xẹp xuống và cái
    // vừa bấm giãn ra. Chúng animate cùng nhịp vì cùng đọc một `expandedID`.
    withAnimation(.snappy(duration: 0.25)) {
      // Đang mở thì bấm lại là đóng (`nil`), còn không thì trỏ sang cái vừa bấm.
      expandedID = (expandedID == panel.id) ? nil : panel.id
    }
  }

  // MARK: Bản dùng đồ có sẵn

  /// Mục 1 đã nói `DisclosureGroup` có bản `isExpanded:`. Chỗ này ráp nốt:
  /// dựng một `Binding` TỰ CHẾ, đọc thì so sánh, ghi thì gán id.
  ///
  /// Nghĩa là single-open không cần tự dựng row. Tự dựng ở trên là để đổi lấy
  /// phần nhìn, không phải vì SwiftUI không làm được.
  private var builtInVersion: some View {
    VStack(alignment: .leading, spacing: 12) {
      ForEach(panels) { panel in
        DisclosureGroup(
          panel.title,
          isExpanded: Binding(
            get: { expandedID == panel.id },
            set: { isOn in
              // Thử bỏ `withAnimation` ra: row BẠN BẤM vẫn mượt vì
              // DisclosureGroup tự gói, nhưng row kia đóng khô khốc — nó đâu
              // biết có ai vừa đổi `expandedID`.
              withAnimation(.snappy(duration: 0.25)) {
                expandedID = isOn ? panel.id : nil
              }
            }
          )
        ) {
          Text(panel.detail)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
    }
    .font(.callout)
  }

  // MARK: Nút

  private var controls: some View {
    Button("Đóng tất cả", systemImage: "arrow.up.to.line") {
      // Đối lập với mục 3: ở đây là đổi GIÁ TRỊ, nên animate được, không mất
      // state nào khác, không dựng lại view nào.
      withAnimation(.snappy(duration: 0.25)) {
        expandedID = nil
      }
    }
    .buttonStyle(.bordered)
    .disabled(expandedID == nil)
    .font(.subheadline)
  }

  // MARK: Ghi chú

  private var notes: some View {
    VStack(alignment: .leading, spacing: 12) {
      Note(
        "Hai row animate cùng nhịp",
        "Cái xẹp xuống và cái giãn ra nằm trong cùng một withAnimation, vì cùng đọc một biến. Ở mục 3 mỗi row có transaction riêng nên không có chuyện đó."
      )
      Note(
        "Muốn LUÔN có đúng một mục mở?",
        "Bỏ Optional đi: `expandedID: Panel.ID`. Lúc đó nil không tồn tại, bấm lại vào mục đang mở thì phép gán không đổi gì. Không cần cờ nào canh — lại là chuyện chọn kiểu dữ liệu, không phải thêm logic."
      )
      Note(
        "Muốn multi-expand mà cha vẫn giữ state?",
        "Đổi `Panel.ID?` thành `Set<Panel.ID>`: isExpanded là `ids.contains(id)`, bấm thì insert/remove. Vẫn một biến ở cha, nhưng chứa được nhiều — đó chính là khác biệt giữa mục 3 và mục 4, nằm gọn trong kiểu dữ liệu."
      )
      Note(
        "Bản DisclosureGroup",
        "Binding tự chế: get so sánh, set gán id. Không cần @State nào cho từng row, và single-open có ngay bằng đồ có sẵn."
      )
    }
  }

  private func SubTitle(_ text: LocalizedStringKey) -> some View {
    Text(text)
      .font(.caption.weight(.semibold))
      .foregroundStyle(.secondary)
  }

  private func Note(_ title: LocalizedStringKey, _ body: LocalizedStringKey) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title).font(.caption.weight(.semibold))
      Text(body).font(.caption).foregroundStyle(.secondary)
    }
  }
}

#Preview {
  NavigationStack {
    SingleOpenAccordionScreen()
  }
}
