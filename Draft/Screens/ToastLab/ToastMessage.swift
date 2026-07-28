//
//  ToastMessage.swift
//  Draft
//
//  Copied from the MaverickToast prototype.
//

import Foundation
import SwiftUI

enum ToastType: CaseIterable {
  case success
  case error
  case warning
  case info

  var color: Color {
    switch self {
    case .success:
      return Color.green
    case .error:
      return Color.red
    case .warning:
      return Color.yellow
    case .info:
      return Color.blue
    }
  }

  var icon: String {
    switch self {
    case .success:
      return "checkmark.circle.fill"
    case .error:
      return "exclamationmark.triangle.fill"
    case .warning:
      return "exclamationmark.circle.fill"
    case .info:
      return "info.circle.fill"
    }
  }
}

struct ToastMessage: Identifiable {
  let id = UUID()
  let title: String
  let message: String?
  let type: ToastType
  /// Seconds before auto-dismiss. `nil` = sticky.
  let duration: Double?
  let closeOnTap: Bool

  init(
    title: String,
    message: String?,
    type: ToastType,
    duration: Double?,
    closeOnTap: Bool = true
  ) {
    self.title = title
    self.message = message
    self.type = type
    self.duration = duration
    self.closeOnTap = closeOnTap
  }
}
