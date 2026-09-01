//
//  SessionPreviewScreen.swift
//  Draft
//
//  Phần 2 — Pipeline của AVFoundation, mới chỉ xem preview.
//
//  Sẽ học:
//  - Mô hình: AVCaptureDevice → AVCaptureDeviceInput → AVCaptureSession → Output.
//  - AVCaptureVideoPreviewLayer bọc qua UIViewRepresentable (layer, không phải view).
//  - beginConfiguration() / commitConfiguration() — đổi cấu hình theo cặp.
//  - startRunning() BLOCK luồng gọi → phải chạy trên session queue riêng, không phải main.
//  - sessionPreset ảnh hưởng gì tới preview và output.
//  - Vòng đời: dừng session khi màn biến mất, nếu không camera vẫn sáng đèn.
//

import SwiftUI

struct SessionPreviewScreen: View {
  var body: some View {
    ContentUnavailableView(
      "Chưa làm",
      systemImage: "video",
      description: Text("Phần 2 — AVCaptureSession + preview layer.")
    )
    .navigationTitle("2. Session & Preview")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    SessionPreviewScreen()
  }
}
