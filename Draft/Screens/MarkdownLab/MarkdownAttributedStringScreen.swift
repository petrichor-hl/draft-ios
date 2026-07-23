//
//  MarkdownAttributedStringScreen.swift
//  Draft
//
//  Stage 2 — AttributedString(markdown:).
//  Bài học: block ĐƯỢC parse (metadata presentationIntent có đủ),
//  nhưng Text VẪN không vẽ được lưới → parse ≠ render.
//

import SwiftUI

struct MarkdownAttributedStringScreen: View {
  private let sample = markdownSamplesFull

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {

        // 2a — Đưa AttributedString(.full) vào Text.
        // Block marker (#, |, -) biến mất → CHỨNG TỎ block đã được parse.
        // Nhưng Text chỉ nối text các run lại: ra 1 cục, mất cả newline.
        stage(
          title: "2a — Text(AttributedString, .full)",
          note: "Block đã parse (mất #,|,-) nhưng Text vẫn ra 1 cục, mất newline → tệ hơn 1b"
        ) {
          Text(fullAttributed)
        }

        // 2b — Bằng chứng: in presentationIntent của TỪNG run.
        // Toạ độ ô bảng / số thứ tự list nằm sẵn đây — Text chỉ là không đọc.
        stage(
          title: "2b — Bằng chứng: block ĐÃ được parse",
          note: "presentationIntent mỗi run. Đủ dữ liệu dựng Grid — nhưng ai đọc?"
        ) {
          runDump
        }
      }
      .padding()
    }
    .navigationTitle("2. AttributedString")
    .navigationBarTitleDisplayMode(.inline)
  }

  // Parse một lần với .full (đầy đủ inline + block).
  private var fullAttributed: AttributedString {
    (try? AttributedString(
      markdown: sample,
      options: .init(interpretedSyntax: .full)
    )) ?? AttributedString("⚠️ parse error")
  }

  // Duyệt từng run, in [intent] + đoạn text tương ứng.
  private var runDump: some View {
    let attr = fullAttributed
    return VStack(alignment: .leading, spacing: 6) {
      ForEach(Array(attr.runs.enumerated()), id: \.offset) { _, run in
        let text = String(attr[run.range].characters)
        let intents = run.presentationIntent?.components.map { label($0.kind) } ?? ["(nil)"]
        HStack(alignment: .top, spacing: 8) {
          Text(intents.joined(separator: " · "))
            .font(.caption2.monospaced())
            .foregroundStyle(color(for: intents))
            .frame(width: 150, alignment: .leading)
          Text("“\(text)”")
            .font(.caption2)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
    }
  }

  // Rút gọn Kind thành nhãn ngắn (mặc định .table in ra cả mảng cột rất dài).
  private func label(_ kind: PresentationIntent.Kind) -> String {
    switch kind {
    case .paragraph: "paragraph"
    case .header(let level): "header \(level)"
    case .orderedList: "orderedList"
    case .unorderedList: "unorderedList"
    case .listItem(let ordinal): "listItem \(ordinal)"
    case .codeBlock(let lang): "codeBlock(\(lang ?? ""))"
    case .blockQuote: "blockQuote"
    case .thematicBreak: "thematicBreak"
    case .table: "table"
    case .tableHeaderRow: "tableHeaderRow"
    case .tableRow(let i): "tableRow \(i)"
    case .tableCell(let i): "tableCell \(i)"
    @unknown default: "?"
    }
  }

  private func color(for intents: [String]) -> Color {
    let joined = intents.joined()
    if joined.contains("table") { return .orange }
    if joined.contains("List") { return .purple }
    if joined.contains("header") { return .blue }
    return .secondary
  }

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
    MarkdownAttributedStringScreen()
  }
}
