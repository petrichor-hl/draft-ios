//
//  ToastManager.swift
//  Draft
//
//  Copied from the MaverickToast prototype.
//
//  Unlike the snack bar, the toast stacks: several can be on screen at once, so
//  frames are kept per id and each toast carries its own auto-dismiss task.
//

import Combine
import Foundation
import SwiftUI

class ToastManager: ObservableObject {
  static let shared = ToastManager()

  @Published var toasts: [ToastMessage] = []

  /// Global-coordinate frames of the visible toasts, keyed by id.
  /// `ToastPassthroughWindow.hitTest` reads these to keep touches landing on a toast
  /// and let empty areas pass through to the window below.
  var toastFrames: [UUID: CGRect] = [:]

  private init() {}

  // MARK: - Public Methods

  @discardableResult
  func showToast(_ toast: ToastMessage) -> UUID {
    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
      toasts.append(toast)
    }
    // Auto-dismiss after `duration` seconds (nil = sticky, no auto-dismiss).
    if let duration = toast.duration {
      Task { @MainActor in
        try? await Task.sleep(for: .seconds(duration))
        dismissToast(toast.id)
      }
    }
    return toast.id
  }

  func dismissToast(_ toastId: UUID) {
    withAnimation(.easeInOut(duration: 0.3)) {
      toasts.removeAll { $0.id == toastId }
    }
  }

  // MARK: - Hit-testing support

  func setFrame(_ frame: CGRect, for id: UUID) {
    toastFrames[id] = frame
  }

  func removeFrame(for id: UUID) {
    toastFrames[id] = nil
  }
}
