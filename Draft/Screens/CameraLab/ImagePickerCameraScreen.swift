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
import AVFoundation

struct ImagePickerCameraScreen: View {
    
    @State private var isCameraPresented = false
    @State private var capturedImage: UIImage?
    
    @State private var cameraMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Group {
                    if let capturedImage {
                        Image(uiImage: capturedImage)
                            .resizable()
                            .scaledToFit()
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "camera")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            
                            Text("No photo yet")
                                .font(.headline)
                            
                            Text("Take a photo to preview it here.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Button {
                    guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                        cameraMessage = "Camera is currently unavailable."
                        return
                    }

                    guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
                        cameraMessage = "Check camera access in Camera Lab → Permission."
                        return
                    }

                    cameraMessage = nil
                    isCameraPresented = true
                } label: {
                    Label(capturedImage == nil ? "Open camera" : "Take another photo", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                if let cameraMessage {
                    Text(cameraMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
        }
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraPicker { image in
                if let image {
                    capturedImage = image
                }
                isCameraPresented = false
            }
            .ignoresSafeArea()
        }
        .navigationTitle("1. ImagePicker")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    var onFinish: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {
        context.coordinator.onFinish = onFinish
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var onFinish: (UIImage?) -> Void
        
        init( onFinish: @escaping (UIImage?) -> Void ) {
            self.onFinish = onFinish
            super.init()
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = info[.originalImage] as? UIImage
            onFinish(image)
        }

        func imagePickerControllerDidCancel(
            _ picker: UIImagePickerController
        ) {
            onFinish(nil)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish)
    }
}

#Preview {
    NavigationStack {
        ImagePickerCameraScreen()
    }
}
