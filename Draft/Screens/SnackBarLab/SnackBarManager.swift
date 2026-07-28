//
//  SnackBarManager.swift
//  Draft
//

import Combine
import Foundation
import SwiftUI

final class SnackBarManager: ObservableObject {
  static let shared = SnackBarManager()
  
  @Published private(set) var current: SnackBarMessage?
  
  private(set) var frame: CGRect?
  private var frameOwnerID: UUID?
  
  private var dismissTask: Task<Void, Never>?
  
  private init() {}
  
  // MARK: - Public Methods
  
  func show<Content: View>(
    action: SnackBarAction? = nil,
    @ViewBuilder content: () -> Content
  ) {
    show(
      SnackBarMessage(action: action, content: content)
    )
  }
  
  func show(_ message: SnackBarMessage) {
    // SnackBar cũ bị thay thế thì timer của nó phải chết theo. Nếu không,
    // timer cũ sẽ đếm hết 4s rồi tắt nhầm snackbar mới.
    dismissTask?.cancel()
    
    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
      current = message
    }
    
    dismissTask = Task { @MainActor in
      try? await Task.sleep(for: .seconds(4))
      guard !Task.isCancelled else { return }
      dismiss()
    }
  }
  
  func dismiss() {
    dismissTask?.cancel()
    dismissTask = nil
    
    withAnimation(.easeInOut(duration: 0.25)) {
      current = nil
    }
  }
  
  /// Bấm action button: chạy callback rồi đóng snackbar ngay.
  func performAction() {
    guard let current else { return }
    current.action?.onPressed()
    dismiss()
  }
  
  // MARK: - Hit-testing support
  func setFrame(_ frame: CGRect, for id: UUID) {
    guard current?.id == id else {
      return
    }
    self.frame = frame
    frameOwnerID = id
  }
  
  func removeFrame(for id: UUID) {
    guard frameOwnerID == id else { return }
    frame = nil
    frameOwnerID = nil
  }
}
