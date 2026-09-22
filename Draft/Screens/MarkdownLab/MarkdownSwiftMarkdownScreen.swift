//
//  MarkdownSwiftMarkdownScreen.swift
//  Draft
//
//  Stage 3 — Apple swift-markdown.
//  Parse ra AST (cây thật) → đệ quy: mỗi loại node map sang 1 View.
//  Nhờ giữ nguyên cây, table/list/heading dựng được thật.
//
//  Lưu ý name-clash: swift-markdown và SwiftUI đều có Text / Table / Link.
//  Nên phải ghi rõ Markdown.Text vs SwiftUI.Text ở những chỗ trùng.
//

import SwiftUI
import Markdown

// TODO: Vá renderer cho đầy đủ hơn
//   [ ] Code block  (``` ```)   → CodeBlock: nền xám + font mono, giữ nguyên xuống dòng
//   [ ] Blockquote  (>)         → BlockQuote: thanh dọc bên trái + thụt lề
//   [ ] Ordered list (1. 2. 3.) → OrderedList: đánh số thay cho "•"
//   [ ] Link bấm được           → đổi inline sang AttributedString có .link (Text + không tap được)
//   [ ] InlineCode kiểu "pill" (như GitHub Markdown: nền xám + đệm + bo góc)
//       → Text + KHÔNG bọc được hộp (.padding/.background trả về View, không phải Text).
//         Muốn pill thật phải bỏ mô hình "1 Text/đoạn", tách paragraph thành mảnh
//         rồi xếp bằng FlowLayout (Layout protocol iOS 16). Cân nhắc sau.

struct MarkdownSwiftMarkdownScreen: View {
  // Parse 1 lần: String → cây AST.
  private let document = Markdown.Document(parsing: markdownSamplesFull)

  var body: some View {
    ScrollView {
      MarkdownBlock(markup: document)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    .navigationTitle("3. swift-markdown")
    .navigationBarTitleDisplayMode(.inline)
  }
}

// MARK: - Render 1 node BLOCK → View (đệ quy)
private struct MarkdownBlock: View {
  let markup: Markup

  var body: some View {
    switch markup {
    case is Markdown.Document:
      // Gốc: xếp các block con theo chiều dọc.
      VStack(alignment: .leading, spacing: 12) {
        children
      }

    case let heading as Heading:
      inlineText(heading).font(headingFont(heading.level))

    case let paragraph as Paragraph:
      inlineText(paragraph)
        .fixedSize(horizontal: false, vertical: true)

    case let table as Markdown.Table:
      tableView(table)

    case is UnorderedList:
      VStack(alignment: .leading, spacing: 4) {
        ForEach(indexed(listItems), id: \.0) { _, item in
          HStack(alignment: .top, spacing: 8) {
            marker(for: item)
            VStack(alignment: .leading, spacing: 4) {
              ForEach(indexed(Array(item.children)), id: \.0) { _, child in
                MarkdownBlock(markup: child)
              }
            }
          }
        }
      }

    default:
      // Node chưa xử lý riêng: cứ render các con của nó.
      children
    }
  }

  // Các block con
  private var children: some View {
    ForEach(indexed(Array(markup.children)), id: \.0) { _, child in
      MarkdownBlock(markup: child)
    }
  }

  private var listItems: [ListItem] {
    markup.children.compactMap { $0 as? ListItem }
  }

  // Marker của mỗi list item. Vì item là ListItem (đã ép ở listItems) nên
  // đọc thẳng .checkbox — đây là lúc as? ListItem không còn thừa nữa.
  @ViewBuilder
  private func marker(for item: ListItem) -> some View {
    switch item.checkbox {
    case .checked?:   Image(systemName: "checkmark.square.fill").foregroundStyle(.tint)
    case .unchecked?: Image(systemName: "square").foregroundStyle(.secondary)
    case nil:         SwiftUI.Text("•")   // item thường, không phải task list
    }
  }

  // Table: gặp Table dựng Grid, Row dựng GridRow — map 1-1 với cây.
  private func tableView(_ table: Markdown.Table) -> some View {
    let headCells = table.head.children.compactMap { $0 as? Markdown.Table.Cell }
    let rows = table.body.children.compactMap { $0 as? Markdown.Table.Row }

    return Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
      GridRow {
        ForEach(indexed(headCells), id: \.0) { _, cell in
          inlineText(cell).bold()
        }
      }
      Divider()
      ForEach(indexed(rows), id: \.0) { _, row in
        GridRow {
          ForEach(indexed(rowCells(row)), id: \.0) { _, cell in
            inlineText(cell)
          }
        }
      }
    }
    .padding(10)
    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.gray.opacity(0.4)))
  }

  private func rowCells(_ row: Markdown.Table.Row) -> [Markdown.Table.Cell] {
    row.children.compactMap { $0 as? Markdown.Table.Cell }
  }

  private func headingFont(_ level: Int) -> Font {
    switch level {
    case 1: .title.bold()
    case 2: .title2.bold()
    case 3: .title3.bold()
    default: .headline
    }
  }
}

// MARK: - Render node INLINE → SwiftUI.Text (ghép bằng toán tử +)
// Inline thì Text làm tốt (đã thấy ở Stage 1), nên ta gộp thành 1 Text.
private func inlineText(_ markup: Markup) -> SwiftUI.Text {
  markup.children.reduce(SwiftUI.Text("")) { $0 + inlineFragment($1) }
}

private func inlineFragment(_ markup: Markup) -> SwiftUI.Text {
  switch markup {
  case let text as Markdown.Text:
    SwiftUI.Text(text.string)
  case let strong as Strong:
    inlineText(strong).bold()
  case let emphasis as Emphasis:
    inlineText(emphasis).italic()
  case let code as InlineCode:
    // Hiện tại: chỉ đổi sang font mono (Text-only nên wrap tốt, nhưng phẳng).
    // Mong muốn: pill kiểu GitHub (nền + đệm + bo góc) — xem TODO đầu file.
    SwiftUI.Text(code.code).font(.system(.body, design: .monospaced))
  case let link as Markdown.Link:
    inlineText(link).foregroundColor(.accentColor).underline()
  case is SoftBreak:
    SwiftUI.Text(" ")
  case is LineBreak:
    SwiftUI.Text("\n")
  default:
    inlineText(markup)
  }
}

// Helper: gắn index làm id cho ForEach (Markup không Identifiable).
private func indexed<T>(_ array: [T]) -> [(Int, T)] {
  Array(array.enumerated())
}

#Preview {
  NavigationStack {
    MarkdownSwiftMarkdownScreen()
  }
}
