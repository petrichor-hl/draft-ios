//
//  VideoRecordingScreen.swift
//  Draft
//
//  Phần 7 — Quay video.
//
//  Sẽ học:
//  - AVCaptureMovieFileOutput: startRecording(to:) ghi thẳng ra file tạm.
//  - Phải thêm audio input riêng → cần NSMicrophoneUsageDescription.
//  - AVCaptureFileOutputRecordingDelegate: didFinishRecordingTo, kể cả khi lỗi vẫn có file.
//  - AVAudioSession: quay video làm gián đoạn nhạc đang phát.
//  - Gián đoạn: cuộc gọi đến, app xuống nền, notification wasInterrupted / interruptionEnded.
//  - Dọn file tạm sau khi copy sang Photos.
//

import SwiftUI

struct VideoRecordingScreen: View {
  var body: some View {
    ContentUnavailableView(
      "Chưa làm",
      systemImage: "record.circle",
      description: Text("Phần 7 — AVCaptureMovieFileOutput.")
    )
    .navigationTitle("7. Quay video")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    VideoRecordingScreen()
  }
}
