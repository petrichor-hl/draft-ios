//
//  AdvancedCaptureScreen.swift
//  Draft
//
//  Phần 9 — Phần sâu, biết là có để khi cần thì tra.
//
//  Sẽ học:
//  - AVCaptureMultiCamSession: trước + sau cùng lúc, kén máy và tốn pin.
//  - Depth data (AVCaptureDepthDataOutput), ảnh chân dung.
//  - Live Photo, ProRAW, HDR — mỗi cái là một kiểu output khác của PhotoOutput.
//  - iOS 18: nút Camera Control vật lý (AVCaptureControl).
//  - systemPressureState / thermalState: máy nóng thì phải tự hạ chất lượng.
//  - Đọc sample code AVCam của Apple để thấy tất cả ghép lại ra sao.
//

import SwiftUI

struct AdvancedCaptureScreen: View {
  var body: some View {
    ContentUnavailableView(
      "Chưa làm",
      systemImage: "camera.aperture",
      description: Text("Phần 9 — multi-cam, depth, Live Photo, Camera Control.")
    )
    .navigationTitle("9. Nâng cao")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    AdvancedCaptureScreen()
  }
}
