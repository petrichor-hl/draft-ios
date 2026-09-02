//
//  AccordionRow.swift
//  Draft
//
//  Bản accordion "sạch" dùng chung cho mục 3, 4, 5 của Accordion Lab.
//  (Mục 2 cố tình giữ bản riêng có công tắc để mổ xẻ, đừng gộp vào đây.)
//
//  ═══════════════════════════════════════════════════════════════════════════
//  CONTROLLED vs UNCONTROLLED — chỗ tách đôi quan trọng nhất của lab
//  ═══════════════════════════════════════════════════════════════════════════
//
//      AccordionRow              KHÔNG nhớ gì. Mở hay đóng do bên ngoài đưa
//                                vào, bấm thì báo ra ngoài bằng `onTap`.
//
//      SelfManagedAccordionRow   Bọc thêm đúng một `@State Bool`.
//
//  Tách ra vì hai mục sau cần hai thứ khác nhau:
//
//      mục 3 (multi-expand)   mỗi row tự giữ state  → SelfManagedAccordionRow
//      mục 4 (single-open)    cha giữ state         → AccordionRow
//
//  Nếu chỉ có bản tự giữ state thì mục 4 không làm được: state nằm trong row,
//  `private`, không ai bên ngoài đọc hay ghi được. Đó không phải hạn chế của
//  SwiftUI mà là hệ quả của việc đặt state sai chỗ.
//

import SwiftUI

// MARK: - Bản controlled: không nhớ gì

struct AccordionRow: View {
  let title: String
  let content: String

  /// Đọc vào, không sở hữu. Row không có quyền tự đổi.
  let isExpanded: Bool

  /// Bấm thì kêu lên, còn làm gì là việc của cha — kể cả việc đóng row khác.
  let onTap: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      Button(action: onTap) {
        HStack {
          Text(title)
            .fontWeight(.medium)

          Spacer()

          Image(systemName: "chevron.down")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .rotationEffect(.degrees(isExpanded ? 180 : 0))
        }
        .padding(16)
        .contentShape(.rect)
      }
      .buttonStyle(.plain)
      .foregroundStyle(.primary)

      if isExpanded {
        Text(content)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 16)
          .padding(.bottom, 16)
      }
    }
  }
}

// MARK: - Bản uncontrolled: tự giữ đúng một bit

struct SelfManagedAccordionRow: View {
  let title: String
  let content: String
  var animation: Animation = .snappy(duration: 0.25)

  @State private var isExpanded = false

  var body: some View {
    AccordionRow(title: title, content: content, isExpanded: isExpanded) {
      withAnimation(animation) {
        isExpanded.toggle()
      }
    }
  }
}

// MARK: - Vỏ ngoài của cả cụm

/// Khối liền bo góc + viền, giống accordion của Bootstrap: góc chỉ bo ở ngoài
/// cùng, các row bên trong ngăn nhau bằng `Divider`.
///
/// Chrome nằm ở ĐÂY chứ không nằm trong từng row — nếu mỗi row tự vẽ viền thì
/// xếp lại sẽ thành các card rời, không ra khối liền.
struct AccordionCard<Content: View>: View {
  @ViewBuilder let content: Content

  var body: some View {
    VStack(spacing: 0) {
      content
    }
    .background(Color(uiColor: .secondarySystemGroupedBackground), in: .rect(cornerRadius: 8))
    .overlay {
      RoundedRectangle(cornerRadius: 8)
        .stroke(Color(uiColor: .separator), lineWidth: 1)
    }
    .clipShape(.rect(cornerRadius: 8))
  }
}
