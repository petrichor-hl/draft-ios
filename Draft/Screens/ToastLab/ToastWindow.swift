//
//  ToastWindow.swift
//  Draft
//
//  Copied from the MaverickToast prototype.
//

import SwiftUI
import UIKit

/// UIWindow cho phép chạm/scroll "xuyên qua" những vùng trống.
///
/// Mặc định một window phủ kín màn hình sẽ nuốt mọi cú chạm. Ta override
/// `hitTest`: nếu cú chạm rơi vào vùng trống thì trả về nil -> hệ thống chuyển
/// sự kiện xuống window phía dưới. Nếu chạm trúng một toast thì trả về subview
/// đó như bình thường.
final class ToastPassthroughWindow: UIWindow {
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard let hitView = super.hitTest(point, with: event) else { return nil }
    // Keep the touch only if it lands on a visible toast (geometry check);
    // otherwise let it pass through to the window below.
    let isOverToast = ToastManager.shared.toastFrames.values.contains { $0.contains(point) }
    return isOverToast ? hitView : nil
  }
}

class ToastWindowManager {
  static let shared = ToastWindowManager()

  private var window: UIWindow?
  private var hostingController: UIHostingController<ToastContainer>?

  private init() {}

  func setup() {
    guard window == nil else { return }

    guard let windowScene = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .first(where: { $0.activationState == .foregroundActive })
    else {
      return
    }

    let window = ToastPassthroughWindow(windowScene: windowScene)
    window.windowLevel = .alert + 1
    window.backgroundColor = .clear
    window.isUserInteractionEnabled = true

    let containerView = ToastContainer()
    let hostingController = UIHostingController(rootView: containerView)
    hostingController.view.backgroundColor = .clear

    window.rootViewController = hostingController
    window.isHidden = false

    self.window = window
    self.hostingController = hostingController
  }
}
