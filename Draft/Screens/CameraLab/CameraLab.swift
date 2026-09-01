//
//  CameraLab.swift
//  Draft
//
//  Menu các cách dùng camera trên iOS, đi từ API cao xuống thấp.
//
//  Ba tầng camera:
//    1. Mượn UI của Apple      — không viết UI, cũng không điều khiển được gì.
//    2. AVCaptureSession       — tự viết UI, Apple lo pipeline.
//    3. Xử lý từng frame       — chặn buffer trước khi nó thành ảnh.
//
//  LƯU Ý: Simulator không có camera — mọi màn từ mục 1 trở đi phải chạy trên iPhone thật.
//

import SwiftUI

struct CameraLab: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Section("Nền tảng") {
        Button {
          coordinator.push(.cameraPermission)
        } label: {
          CameraLabRow(
            title: "0. Permission",
            subtitle: "NSCameraUsageDescription, authorizationStatus, mở Settings"
          )
        }
      }

      Section("Mượn UI của Apple") {
        Button {
          coordinator.push(.cameraImagePicker)
        } label: {
          CameraLabRow(
            title: "1. UIImagePickerController ⭐️",
            subtitle: "Chụp ảnh trong ~40 dòng, không cần AVFoundation"
          )
        }
      }

      Section("AVFoundation — tự viết UI") {
        Button {
          coordinator.push(.cameraSessionPreview)
        } label: {
          CameraLabRow(
            title: "2. Session & Preview",
            subtitle: "Device → Input → Session → PreviewLayer, chưa chụp"
          )
        }

        Button {
          coordinator.push(.cameraPhotoCapture)
        } label: {
          CameraLabRow(
            title: "3. Chụp ảnh",
            subtitle: "AVCapturePhotoOutput, delegate, orientation, lưu Photos"
          )
        }

        Button {
          coordinator.push(.cameraControls)
        } label: {
          CameraLabRow(
            title: "4. Điều khiển camera",
            subtitle: "Đổi ống kính, flash/torch, zoom, tap-to-focus, xoay máy"
          )
        }

        Button {
          coordinator.push(.cameraVideoRecording)
        } label: {
          CameraLabRow(
            title: "5. Quay video",
            subtitle: "MovieFileOutput, thêm audio input, gián đoạn cuộc gọi"
          )
        }

        Button {
          coordinator.push(.cameraMetadataScan)
        } label: {
          CameraLabRow(
            title: "6. Quét QR / barcode",
            subtitle: "AVCaptureMetadataOutput — dùng session rẻ nhất"
          )
        }
      }

      Section {
        Button {
          coordinator.push(.cameraVideoDataOutput)
        } label: {
          CameraLabRow(
            title: "7. Xử lý từng frame",
            subtitle: "CMSampleBuffer, filter Core Image, Vision realtime"
          )
        }

        Button {
          coordinator.push(.cameraAdvanced)
        } label: {
          CameraLabRow(
            title: "8. Nâng cao",
            subtitle: "Multi-cam, depth, Live Photo, Camera Control, nhiệt độ máy"
          )
        }
      } footer: {
        Text("Simulator không có camera: isSourceTypeAvailable(.camera) trả về false, AVCaptureDevice.default(...) trả về nil. Phải chạy trên iPhone thật.")
      }
    }
    .navigationTitle("Camera Lab")
  }
}

#Preview {
  NavigationStack {
    CameraLab()
      .environment(AppCoordinator())
  }
}
