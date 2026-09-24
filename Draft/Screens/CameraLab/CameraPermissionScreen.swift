//
//  CameraPermissionScreen.swift
//  Draft
//
//  Phần 0 — Xin quyền.
//
//  Quyền không do app giữ. TCC (Transparency, Consent, and Control) của hệ thống mới là
//  nguồn sự thật: app chỉ hỏi rồi nhận kết quả, nên phải đọc lại mỗi lần cần.
//
//  Sẽ học:
//  - INFOPLIST_KEY_NSCameraUsageDescription (project này không có file Info.plist,
//    key nằm ở Build Settings). Thiếu key → app crash ngay lần đụng camera đầu tiên,
//    không phải trả về denied.
//  - AVCaptureDevice.authorizationStatus(for: .video): notDetermined / restricted / denied / authorized.
//    denied thì user tự sửa được, restricted (Screen Time, MDM) thì không — đừng dẫn họ sang Settings.
//  - AVCaptureDevice.requestAccess(for:) — chỉ hiện dialog đúng MỘT lần trong đời app.
//  - Bị denied thì không xin lại được, phải mở Settings bằng @Environment(\.openURL) hoặc UIApplication.shared.open(...)
//  - Trạng thái đổi sau lưng app (user sang Settings rồi quay lại) → đọc lại theo scenePhase.
//  - Quyền lưu ảnh là quyền KHÁC: PHPhotoLibrary + INFOPLIST_KEY_NSPhotoLibraryAddUsageDescription (add-only).
//
//  Test nhanh (Simulator chạy được phần này vì chỉ hỏi TCC, chưa mở camera):
//    xcrun simctl privacy booted reset  camera com.petrichor.Draft   → notDetermined
//    xcrun simctl privacy booted revoke camera com.petrichor.Draft   → denied
//    xcrun simctl privacy booted grant  camera com.petrichor.Draft   → authorized
//
//    xcrun simctl privacy booted reset photos-add com.petrichor.Draft
//

import SwiftUI
import AVFoundation
import Photos

struct CameraPermissionScreen: View {
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.openURL) private var openURL
  
  @State private var cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
  @State private var photoStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)
  
  var body: some View {
    List {
      Section {
        LabeledContent("Trạng thái") {
          Text(cameraStatus.label)
        }
        cameraActionButton
      } header: {
        Text("Camera")
      } footer: {
        Text(cameraStatus.explain)
      }
      
      Section {
        LabeledContent("Trạng thái") {
          Text(photoStatus.label)
        }
        photoActionButton
      } header: {
        Text("Lưu vào Photos (add-only)")
      } footer: {
        Text(photoStatus.explain)
      }
    }
    .navigationTitle("0. Permission")
    .navigationBarTitleDisplayMode(.inline)
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        refreshStatuses()
      }
    }
  }
  
  @ViewBuilder
  private var cameraActionButton: some View {
    switch cameraStatus {
    case .notDetermined:
      Button("Xin quyền camera") {
        Task { await requestCamera() }
      }
    case .denied:
      Button("Mở Settings") { openAppSettings() }
    default:
      EmptyView()
    }
  }

  private func requestCamera() async {
    _ = await AVCaptureDevice.requestAccess(for: .video)
    cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
  }
  
  @ViewBuilder
  private var photoActionButton: some View {
    switch photoStatus {
    case .notDetermined:
      Button("Xin quyền lưu ảnh") {
        Task { await requestPhotoAddOnly() }
      }
    case .denied:
      Button("Mở Settings") { openAppSettings() }
    default:
      EmptyView()
    }
  }

  private func requestPhotoAddOnly() async {
    photoStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
  }
  
  private func openAppSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    openURL(url)
  }
  
  private func refreshStatuses() {
    cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
    photoStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)
  }
}

private extension AVAuthorizationStatus {
  var label: LocalizedStringKey {
    switch self {
    case .notDetermined: "Chưa hỏi"
    case .restricted:    "Bị hệ thống chặn"
    case .denied:        "User đã từ chối"
    case .authorized:    "Đã cho phép"
    @unknown default:    "Không rõ"
    }
  }
  
  var explain: LocalizedStringKey {
    switch self {
    case .notDetermined: "Gọi requestAccess sẽ hiện dialog."
    case .restricted:    "Screen Time hoặc MDM chặn. User không tự bật được."
    case .denied:        "Dialog sẽ KHÔNG hiện lại. Phải sang Settings."
    case .authorized:    "Mở session được rồi."
    @unknown default:    "Case mới của hệ điều hành."
    }
  }
}

private extension PHAuthorizationStatus {
  var label: LocalizedStringKey {
    switch self {
    case .notDetermined: "Chưa hỏi"
    case .restricted:    "Bị hệ thống chặn"
    case .denied:        "User đã từ chối"
    case .authorized:    "Đã cho phép"
    case .limited:       "Giới hạn"
    @unknown default:    "Không rõ"
    }
  }

  var explain: LocalizedStringKey {
    switch self {
    case .notDetermined: "Gọi requestAuthorization sẽ hiện dialog."
    case .restricted:    "Screen Time hoặc MDM chặn."
    case .denied:        "Vào Settings → Ứng dụng → Draft → Ảnh để bật."
    case .authorized:    "Lưu ảnh được rồi. Vẫn KHÔNG đọc được thư viện."
    case .limited:       "Chỉ gặp ở mức readWrite, không gặp với addOnly."
    @unknown default:    "Case mới của hệ điều hành."
    }
  }
}
