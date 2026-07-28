//
//  ToastContainer.swift
//  Draft
//
//  Copied from the MaverickToast prototype.
//

import SwiftUI

struct ToastContainer: View {
  @ObservedObject private var toastManager = ToastManager.shared

  var body: some View {
    VStack {
      ForEach(toastManager.toasts.suffix(3)) { toast in
        ToastView(
          toast: toast,
          onTap: {
            if toast.closeOnTap {
              toastManager.dismissToast(toast.id)
            }
          }
        )
        .transition(.move(edge: .top).combined(with: .opacity))
        .background(
          GeometryReader { geo in
            Color.clear
              .onAppear {
                toastManager.setFrame(geo.frame(in: .global), for: toast.id)
              }
              .onChange(of: geo.frame(in: .global)) { _, newFrame in
                toastManager.setFrame(newFrame, for: toast.id)
              }
              .onDisappear {
                toastManager.removeFrame(for: toast.id)
              }
          }
        )
      }

      Spacer()
    }
    .padding(.horizontal, 16)
  }
}
