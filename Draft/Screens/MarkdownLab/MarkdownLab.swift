//
//  MarkdownLab.swift
//  Draft
//
//  Created by Lam Tran  on 13/7/26.
//
//  Menu 3 cách render markdown, học theo thứ tự để thấy limitation
//  của cách trước đẩy ta sang cách sau.
//

import SwiftUI

struct MarkdownLab: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Button {
        coordinator.push(.markdownText)
      } label: {
        LabRow(title: "1. Text",
               subtitle: "Native, 0 dependency — chỉ inline")
      }

      Button {
        coordinator.push(.markdownAttributedString)
      } label: {
        LabRow(title: "2. AttributedString",
               subtitle: "Parse được block, nhưng render thì sao?")
      }

      Button {
        coordinator.push(.markdownSwiftMarkdown)
      } label: {
        LabRow(title: "3. swift-markdown",
               subtitle: "Parse ra AST → tự render đủ table/list")
      }
    }
    .navigationTitle("Markdown Lab")
  }
}

// Một dòng trong danh sách: tiêu đề + mô tả ngắn
private struct LabRow: View {
  let title: LocalizedStringKey
  let subtitle: LocalizedStringKey

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title).font(.headline)
      Text(subtitle).font(.caption).foregroundStyle(.secondary)
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  NavigationStack {
    MarkdownLab()
      .environment(AppCoordinator())
  }
}
