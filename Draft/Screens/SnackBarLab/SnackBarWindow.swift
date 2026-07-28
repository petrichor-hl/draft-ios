//
//  SnackBarWindow.swift
//  Draft
//

import SwiftUI
import UIKit

final class PassthroughWindow: UIWindow {
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard let hitView = super.hitTest(point, with: event) else { return nil }
    guard let frame = SnackBarManager.shared.frame, frame.contains(point) else { return nil }
    return hitView
  }
}

final class SnackBarWindowManager {
  static let shared = SnackBarWindowManager()
  
  private var window: UIWindow?
  private var hostingController: UIHostingController<SnackBarContainer>?
  
  private init() {}
  
  func setup() {
    guard window == nil else { return }
    
    guard let windowScene = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .first(where: { $0.activationState == .foregroundActive })
    else {
      return
    }
    
    let window = PassthroughWindow(windowScene: windowScene)
    window.windowLevel = .alert + 1
    window.backgroundColor = .clear
    window.isUserInteractionEnabled = true
    
    let hostingController = UIHostingController(rootView: SnackBarContainer())
    hostingController.view.backgroundColor = .clear
    
    window.rootViewController = hostingController
    window.isHidden = false
    
    self.window = window
    self.hostingController = hostingController
  }
}
