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
    
    @State private var camera = CameraSessionController()
    
    @State private var isPreviewVisible = false
    
    @State private var isSwitchingCamera = false
    
    @State private var capturedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 16) {
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
            .background(Color(uiColor: .secondarySystemBackground), in: .rect(cornerRadius: 20))
            
            Button {
                isPreviewVisible = true
            } label: {
                Label("Open camera", systemImage: "camera")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Spacer()
        }
        .padding()
        .onAppear {
            camera.onPhotoCaptured = { data in
                guard let image = UIImage(data: data) else {
                    print("Unable to decode photo.")
                    return
                }
                
                capturedImage = image
                isPreviewVisible = false
            }
        }
        .fullScreenCover(isPresented: $isPreviewVisible) {
            ZStack() {
                CameraPreview(session: camera.captureSession)
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Spacer()
                        closeButton
                    }
                    
                    Spacer()
                    
                    HStack {
                        galleryButton
                        Spacer()
                        captureButton
                        Spacer()
                        switchCameraButton
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                camera.start()
            }
            .onDisappear {
                camera.stop()
            }
        }
        .navigationTitle("5. Chụp ảnh")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var captureButton: some View {
        Button {
            camera.capturePhoto()
        } label: {
            Circle()
                .fill(.white)
                .frame(width: 64, height: 64)
                .padding(5)
                .overlay {
                    Circle()
                        .stroke(.white, lineWidth: 2)
                }
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .disabled(isSwitchingCamera)
    }
    
    private var closeButton: some View {
        Button {
            isPreviewVisible = false
        } label: {
            Image(systemName: "xmark")
                .font(.headline)
                .frame(width: 44, height: 44)
                .background(.regularMaterial, in: .circle)
        }
        .buttonStyle(.plain)
    }
    
    private var galleryButton: some View {
        Button {
            // TODO: Open the photo library in a later step.
        } label: {
            Image(systemName: "photo.fill")
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.black.opacity(0.35), in: .circle)
        }
        .buttonStyle(.plain)
    }
    
    private var switchCameraButton: some View {
        Button {
            isSwitchingCamera = true
            
            Task {
                defer { isSwitchingCamera = false }
                await camera.switchCamera()
            }
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.black.opacity(0.35), in: .circle)
        }
        .buttonStyle(.plain)
        .disabled(isSwitchingCamera)
    }
}
