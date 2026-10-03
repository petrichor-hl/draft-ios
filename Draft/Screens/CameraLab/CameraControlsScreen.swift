//
//  CameraControlsScreen.swift
//  Draft
//
//  Phần 6 — Những nút mà app camera thật nào cũng có.
//
//  Sẽ học:
//  - Đổi trước/sau: gỡ input cũ, thêm input mới trong cùng một beginConfiguration().
//  - flashMode (lúc chụp) khác torchMode (đèn pin bật liên tục).
//  - Zoom: videoZoomFactor và virtual device (ultra-wide / wide / tele nằm chung một device).
//  - lockForConfiguration() / unlockForConfiguration() — mọi thay đổi trên device đều cần.
//  - Tap-to-focus: đổi toạ độ view → toạ độ device bằng captureDevicePointConverted.
//  - AVCaptureDevice.RotationCoordinator (iOS 17+) thay cho việc tự nghe xoay máy.
//

import SwiftUI

struct CameraControlsScreen: View {
  var body: some View {
    ContentUnavailableView(
      "Chưa làm",
      systemImage: "slider.horizontal.3",
      description: Text("Phần 6 — đổi ống kính, flash, zoom, focus, xoay.")
    )
    .navigationTitle("6. Điều khiển")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    CameraControlsScreen()
  }
}
