//
//  ToolbarDoneScreen.swift
//  Draft
//

import SwiftUI

struct ToolbarDoneScreen: View {
  private enum Field {
    case title
    case description
  }

  @State private var title = ""
  @State private var description = ""
  @FocusState private var focusedField: Field?

  var body: some View {
    Form {
      Section("Hai ô, một toolbar") {
        TextField("Tiêu đề", text: $title)
          .focused($focusedField, equals: .title)

        TextField("Mô tả", text: $description, axis: .vertical)
          .lineLimit(3...6)
          .focused($focusedField, equals: .description)
      }

      Section("Đang focus") {
        Text(focusLabel)
          .foregroundStyle(.secondary)
      }
    }
    .toolbar {
      ToolbarItemGroup(placement: .keyboard) {
        if focusedField != nil {
          Spacer()
          Button("Xong") {
            focusedField = nil
          }
          .fontWeight(.semibold)
        }
      }
    }
    .navigationTitle("Toolbar Done")
    .navigationBarTitleDisplayMode(.inline)
  }

  private var focusLabel: String {
    switch focusedField {
    case .title: "Tiêu đề"
    case .description: "Mô tả"
    case nil: "Không ô nào"
    }
  }
}

#Preview {
  NavigationStack {
    ToolbarDoneScreen()
  }
}
