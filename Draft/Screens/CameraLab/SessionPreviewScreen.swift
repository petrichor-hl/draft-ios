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
//  - start() cấu hình ở lần đầu rồi chạy session trên sessionQueue.
//  - startRunning() BLOCK luồng gọi → phải chạy trên session queue riêng, không phải main.
//  - Vòng đời: chủ động dừng session khi preview biến mất.
//
//  sessionPreset được học riêng ở bài 4. Session Preset (tùy chọn).
//
//  Official documentation:
//  - https://developer.apple.com/documentation/avfoundation/capture-setup
//  - https://developer.apple.com/documentation/avfoundation/setting-up-a-capture-session
//  - https://developer.apple.com/documentation/avfoundation/avcam-building-a-camera-app
//  - https://developer.apple.com/documentation/avfoundation/building-a-responsive-camera-app-that-launches-quickly
//

import SwiftUI
import AVFoundation

struct SessionPreviewScreen: View {
    
    @State private var camera = CameraSessionController()
    @State private var isPreviewVisible = false
    
    var body: some View {
        VStack(spacing: 16) {
            Button {
                isPreviewVisible = true
            } label: {
                Label("Open camera", systemImage: "camera")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .fullScreenCover(isPresented: $isPreviewVisible) {
            ZStack(alignment: .topTrailing) {
                CameraPreview(session: camera.captureSession)
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
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                camera.start()
            }
            // Test thủ công trên iPhone với session chỉ có preview hiện tại:
            // Mở camera → Close → chờ chỉ báo xanh tắt → nhấn "Print session state".
            // - Bỏ camera.stop(): isRunning = true, isInterrupted = false.
            // - Gọi camera.stop() trong onDisappear: isRunning = false, isInterrupted = false.
            // Trong thử nghiệm này, chỉ báo xanh tắt chưa đủ để kết luận session đã stopped.
            // Các giá trị trên không xác định mức sử dụng phần cứng hay tài nguyên.
            .onDisappear {
                camera.stop()
            }
        }
        .navigationTitle("2. Session & Preview")
        .navigationBarTitleDisplayMode(.inline)
    }
}

final class CameraPreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(
        _ uiView: CameraPreviewView,
        context: Context
    ) {
    }
}
