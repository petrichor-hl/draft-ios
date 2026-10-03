//
//  PhotoCaptureScreen.swift
//  Draft
//
//  Phần 5 — Bấm nút là ra ảnh.
//
//  Sẽ học:
//  - AVCapturePhotoOutput gắn vào session ở phần 2.
//  - AVCapturePhotoSettings: mỗi lần chụp phải tạo settings MỚI, dùng lại là crash.
//  - AVCapturePhotoCaptureDelegate: didFinishProcessingPhoto → fileDataRepresentation().
//  - Vì sao ảnh bị xoay: orientation của ảnh chụp không theo hướng UI.
//  - Lưu vào Photos bằng PHPhotoLibrary.performChanges + PHAssetCreationRequest.
//

import SwiftUI

struct PhotoCaptureScreen: View {
  var body: some View {
    ContentUnavailableView(
      "Chưa làm",
      systemImage: "camera.shutter.button",
      description: Text("Phần 5 — AVCapturePhotoOutput và lưu ảnh.")
    )
    .navigationTitle("5. Chụp ảnh")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    PhotoCaptureScreen()
  }
}
