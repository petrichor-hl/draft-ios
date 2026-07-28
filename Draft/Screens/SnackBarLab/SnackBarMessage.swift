//
//  SnackBarMessage.swift
//  Draft
//

import SwiftUI

struct SnackBarMessage: Identifiable {
  let id = UUID()
  let content: AnyView
  let action: SnackBarAction?

  init<Content: View>(
    action: SnackBarAction? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.content = AnyView(content())
    self.action = action
  }
}

struct SnackBarAction {
  let label: String
  let onPressed: () -> Void

  init(label: String, onPressed: @escaping () -> Void) {
    self.label = label
    self.onPressed = onPressed
  }
}
