//
//  MarkdownTextScreen.swift
//  Draft
//
//  Stage 1 — Render bằng SwiftUI Text.
//  Mục tiêu: thấy 2 limitation liên tiếp đẩy ta sang AttributedString.
//

import SwiftUI

struct MarkdownTextScreen: View {

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {

        // 1a — Truyền một String (biến) vào Text.
        // Limitation #1: markdown KHÔNG được parse, in ra nguyên si
        // dấu **, #, |. Vì auto-parse chỉ chạy với String LITERAL
        // (qua LocalizedStringKey), không chạy với biến String.
        stage(
          title: "1a — Text(String biến)",
          note: "Markdown không được parse → thấy nguyên **, #, |"
        ) {
          Text(markdownSamplesFull)
        }

        // 1b — Ép về LocalizedStringKey để Text chịu parse markdown.
        // Inline (bold/italic/code/link) giờ đẹp.
        // Limitation #2: table / list / heading vẫn hỏng — vì Text
        // chỉ parse INLINE, không dựng được block-level layout.
        stage(
          title: "1b — Text(LocalizedStringKey)",
          note: "Inline OK. Nhưng table/list/heading vẫn gãy"
        ) {
          Text(LocalizedStringKey(markdownSamplesFull))
        }
      }
      .padding()
    }
    .navigationTitle("1. Text")
    .navigationBarTitleDisplayMode(.inline)
  }

  // Helper: mỗi stage có tiêu đề + ghi chú + khung, dễ so sánh bằng mắt.
  @ViewBuilder
  private func stage<Content: View>(
    title: String,
    note: String,
    @ViewBuilder content: () -> Content
  ) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title).font(.headline)
      Text(note).font(.caption).foregroundStyle(.secondary)
      content()
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.gray.opacity(0.1), in: .rect(cornerRadius: 8))
    }
  }
}

#Preview {
  NavigationStack {
    MarkdownTextScreen()
  }
}
