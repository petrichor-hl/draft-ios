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
//  - startRunning() BLOCK luồng gọi → phải chạy trên session queue riêng, không phải main.
//  - Vòng đời: chủ động dừng session khi preview biến mất.
//
//  Bước tùy chọn sau bài này:
//  - sessionPreset ảnh hưởng gì tới preview và output, canSetSessionPreset,
//    đổi preset khi preview đang hiển thị.
//  - Không yêu cầu bước này để hoàn thành Session & Preview.
//

import SwiftUI
import AVFoundation

struct SessionPreviewScreen: View {
    //    @Environment(\.scenePhase) private var scenePhase
    
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
            
            Button("Print session state") {
                camera.printSessionState()
            }
            .buttonStyle(.bordered)
        }
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
            //            .onChange(of: scenePhase) { _, phase in
            //                if phase == .active && isPreviewVisible {
            //                    camera.start()
            //                } else {
            //                    camera.stop()
            //                }
            //            }
        }
        .navigationTitle("2. Session & Preview")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
}

// @unchecked Sendable means we take responsibility for synchronization ourselves.
nonisolated final class CameraSessionController: @unchecked Sendable {
    let session = AVCaptureSession()
    private var isConfigured = false
    
    private let sessionQueue = DispatchQueue(label: "camera.session")
    
    private func makeCameraInput() throws -> AVCaptureDeviceInput? {
        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else {
            return nil
        }
        
        return try AVCaptureDeviceInput(device: device)
    }
    
    private func configureSession() throws -> Bool {
        guard let input = try makeCameraInput() else {
            return false
        }
        
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        
        guard session.canAddInput(input) else {
            return false
        }
        
        session.addInput(input)
        return true
    }
    
    func start() {
        sessionQueue.async { [self] in
            guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
                print("Check camera access in Camera Lab → Permission.")
                return
            }
            
            do {
                if !isConfigured {
                    isConfigured = try configureSession()
                }
                
                guard isConfigured else {
                    print("Unable to configure the camera session.")
                    return
                }
                
                if !session.isRunning {
                    session.startRunning()
                }
            } catch {
                print("Camera setup failed: \(error.localizedDescription)")
            }
        }
    }
    
    func stop() {
        sessionQueue.async { [self] in
            if session.isRunning {
                session.stopRunning()
            }
        }
    }
    
    func printSessionState() {
        sessionQueue.async { [self] in
            print("isRunning:", session.isRunning)
            print("isInterrupted:", session.isInterrupted)
        }
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
