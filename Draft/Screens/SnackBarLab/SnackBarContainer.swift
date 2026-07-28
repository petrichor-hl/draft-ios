//
//  SnackBarContainer.swift
//  Draft
//

import SwiftUI

/// Root view của snackbar window: neo snackbar ở đáy màn hình.
struct SnackBarContainer: View {
  @ObservedObject private var manager = SnackBarManager.shared
  
  var body: some View {
    VStack {
      Spacer(minLength: 0)
      
      if let message = manager.current {
        SnackBarView(message: message) {
          manager.performAction()
        }
        // frameReader phải nằm *trong* .id để mỗi snackbar có reader riêng.
        // Nếu đặt ngoài, reader dùng chung sẽ không chạy lại onAppear cho
        // snackbar mới, và id mà nó báo về không còn khớp view nó đang đo.
        .background(frameReader(for: message.id))
        // Đổi id khi replace để SwiftUI coi đây là view mới -> có
        // transition ra/vào, thay vì chỉ đổi chữ tại chỗ.
        .id(message.id)
        .transition(.move(edge: .bottom).combined(with: .opacity))
      }
    }
    .padding(.horizontal, 16)
    .padding(.bottom, 16)
  }
  
  // MARK: - Views
  
  /// Báo frame global của snackbar cho `SnackBarPassthroughWindow` hit-test.
  private func frameReader(for id: UUID) -> some View {
    GeometryReader { geo in
      Color.clear
        .onAppear {
          manager.setFrame(geo.frame(in: .global), for: id)
        }
        .onChange(of: geo.frame(in: .global)) { _, newFrame in
          manager.setFrame(newFrame, for: id)
        }
        .onDisappear {
          manager.removeFrame(for: id)
        }
    }
  }
}
