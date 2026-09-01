//
//  ImagePickerCameraScreen.swift
//  Draft
//
//  Phần 1 — Mượn UI camera của Apple.
//
//  Sẽ học:
//  - UIImagePickerController với sourceType = .camera, bọc bằng UIViewControllerRepresentable.
//  - Coordinator làm delegate: didFinishPickingMediaWithInfo, imagePickerControllerDidCancel.
//  - isSourceTypeAvailable(.camera) — false trên Simulator, phải fallback.
//  - So sánh với LearnPhotoPicker: PhotosPicker = thư viện, cái này = chụp mới.
//  - Giới hạn: không đổi được UI, không kiểm soát chất lượng/ống kính → lý do có phần 2.
//

import SwiftUI

struct ImagePickerCameraScreen: View {
  var body: some View {
    ContentUnavailableView(
      "Chưa làm",
      systemImage: "camera",
      description: Text("Phần 1 — UIImagePickerController bọc trong SwiftUI.")
    )
    .navigationTitle("1. ImagePicker")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    ImagePickerCameraScreen()
  }
}
