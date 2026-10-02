//
//  SessionPresetScreen.swift
//  Draft
//
//  Bài 3 — Session Preset (tùy chọn, sau Session & Preview).
//
//  Sẽ học:
//  - sessionPreset cấu hình chất lượng và định dạng capture; mặc định là .high.
//  - Thử ba quality levels: .low, .medium và .high.
//  - Thử .photo và High definition trên iOS: 720p, 1080p, 4K.
//    qHD960x540 chỉ có trên macOS, không hỗ trợ iOS.
//  - canSetSessionPreset kiểm tra preset với cấu hình session hiện tại.
//  - Đổi preset trên session queue trong beginConfiguration() / commitConfiguration().
//  - Thử đổi preset khi preview đang hiển thị; phân biệt với videoGravity.
//

import SwiftUI
import AVFoundation

struct SessionPresetScreen: View {
  @State private var camera = CameraSessionController()
  @State private var isPreviewVisible = false

  var body: some View {
    Button {
      isPreviewVisible = true
    } label: {
      Label("Open camera", systemImage: "camera")
    }
    .buttonStyle(.borderedProminent)
    .controlSize(.large)
    .fullScreenCover(isPresented: $isPreviewVisible) {
      ZStack(alignment: .topTrailing) {
        CameraPreview(session: camera.session)
          .ignoresSafeArea()

        Button {
          isPreviewVisible = false
        } label: {
          Image(systemName: "xmark")
            .font(.headline)
            .frame(width: 44, height: 44)
            .background(.regularMaterial, in: .circle)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close camera")
        .padding()
      }
      .safeAreaInset(edge: .bottom) {
        ScrollView(.horizontal) {
          HStack {
            Button("Low") {
              camera.changePreset(.low)
            }

            Button("Medium") {
              camera.changePreset(.medium)
            }

            Button("High") {
              camera.changePreset(.high)
            }

            Button("Photo") {
              camera.changePreset(.photo)
            }

            Button("720p") {
              camera.changePreset(.hd1280x720)
            }

            Button("1080p") {
              camera.changePreset(.hd1920x1080)
            }

            Button("4K") {
              camera.changePreset(.hd4K3840x2160)
            }
          }
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
        }
        .background(.regularMaterial)   // --> Mở rộng màu background xuống cả vùng home indicator
        // .background(.regularMaterial, in: .rect)
        // --> vẽ shape theo vùng của view, vùng home indicator không được tô màu
        .scrollIndicators(.hidden)
      }
      .onAppear {
        camera.start()
      }
      .onDisappear {
        camera.stop()
      }
    }
    .navigationTitle("3. Session Preset")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    SessionPresetScreen()
  }
}
