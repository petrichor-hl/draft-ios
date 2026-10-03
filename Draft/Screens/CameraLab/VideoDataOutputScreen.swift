//
//  VideoDataOutputScreen.swift
//  Draft
//
//  Phần 9 — Chặn từng frame trước khi nó thành ảnh.
//
//  Sẽ học:
//  - AVCaptureVideoDataOutput + delegate trả CMSampleBuffer trên queue riêng.
//  - alwaysDiscardsLateVideoFrames: xử lý chậm thì bỏ frame, đừng xếp hàng.
//  - CMSampleBuffer → CVPixelBuffer → CIImage, và vì sao KHÔNG được giữ buffer lâu.
//  - Preview tự vẽ: Core Image + Metal thay cho AVCaptureVideoPreviewLayer.
//  - Đẩy buffer sang Vision (nhận diện khuôn mặt, chữ) chạy realtime.
//

import SwiftUI

struct VideoDataOutputScreen: View {
  var body: some View {
    ContentUnavailableView(
      "Chưa làm",
      systemImage: "square.stack.3d.down.right",
      description: Text("Phần 9 — sample buffer, Core Image, Vision.")
    )
    .navigationTitle("9. Xử lý frame")
    .navigationBarTitleDisplayMode(.inline)
  }
}
