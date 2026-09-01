//
//  CameraPermissionScreen.swift
//  Draft
//
//  Phần 0 — Xin quyền.
//
//  Sẽ học:
//  - INFOPLIST_KEY_NSCameraUsageDescription (project này không có file Info.plist,
//    key nằm ở Build Settings). Thiếu key → app crash ngay lần đụng camera đầu tiên.
//  - AVCaptureDevice.authorizationStatus(for: .video): notDetermined / restricted / denied / authorized
//  - AVCaptureDevice.requestAccess(for:) — chỉ hiện dialog đúng MỘT lần trong đời app.
//  - Bị denied thì không xin lại được: phải đưa user sang Settings bằng
//    UIApplication.openSettingsURLString.
//  - Quyền lưu ảnh là quyền KHÁC: PHPhotoLibrary + NSPhotoLibraryAddUsageDescription (add-only).
//

import SwiftUI

struct CameraPermissionScreen: View {
  var body: some View {
    ContentUnavailableView(
      "Chưa làm",
      systemImage: "hand.raised",
      description: Text("Phần 0 — quyền camera & quyền lưu ảnh.")
    )
    .navigationTitle("0. Permission")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    CameraPermissionScreen()
  }
}
