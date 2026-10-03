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
            
            Button("Print session state") {
                camera.printSessionState()
            }
            .buttonStyle(.bordered)
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

// @unchecked Sendable means we take responsibility for synchronization ourselves.
nonisolated final class CameraSessionController: @unchecked Sendable {
    let captureSession = AVCaptureSession()
    let supportsUltraWide = AVCaptureDevice.default(
        .builtInUltraWideCamera,
        for: .video,
        position: .back
    ) != nil
    private var isConfigured = false
    private var videoInput: AVCaptureDeviceInput?
    
    private let sessionQueue = DispatchQueue(label: "camera.session")   // a serial queue
    
    private func configureSession() -> Bool {
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        let videoDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        )
        
        guard
            let videoDevice,
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
            captureSession.canAddInput(videoDeviceInput)
        else {
            return false
        }
        
        captureSession.addInput(videoDeviceInput)
        videoInput = videoDeviceInput
        return true
    }
    
    func start() {
        sessionQueue.async { [self] in
            guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
                print("Check camera access in Camera Lab → Permission.")
                return
            }
            
            if !isConfigured {
                isConfigured = configureSession()
            }
            
            guard isConfigured else {
                print("Unable to configure the camera session.")
                return
            }
            
            if !captureSession.isRunning {
                captureSession.startRunning()
            }
        }
    }
    
    func stop() {
        sessionQueue.async { [self] in
            if captureSession.isRunning {
                captureSession.stopRunning()
            }
        }
    }
    
    func changePreset(_ preset: AVCaptureSession.Preset) {
        sessionQueue.async { [self] in
            guard captureSession.canSetSessionPreset(preset) else {
                print("Preset không được hỗ trợ:", preset.rawValue)
                return
            }

            captureSession.beginConfiguration()
            captureSession.sessionPreset = preset
            captureSession.commitConfiguration()

            print("Preset:", captureSession.sessionPreset.rawValue)
        }
    }

    func changeZoom(_ zoom: Double) async -> Bool {
        await withCheckedContinuation { continuation in
            sessionQueue.async { [self] in
                continuation.resume(returning: switchCamera(for: zoom))
            }
        }
    }

    private func switchCamera(for zoom: Double) -> Bool {
        guard zoom == 0.5 || zoom == 1.0, let currentInput = videoInput else {
            return false
        }

        // 0.5x và 1x là tên hiển thị tương đối với ống kính wide.
        // Mỗi camera vật lý vẫn dùng videoZoomFactor mặc định là 1.
        let deviceType: AVCaptureDevice.DeviceType = zoom == 0.5
            ? .builtInUltraWideCamera
            : .builtInWideAngleCamera

        if currentInput.device.deviceType == deviceType {
            return true
        }

        guard
            let device = AVCaptureDevice.default(deviceType, for: .video, position: .back),
            let newInput = try? AVCaptureDeviceInput(device: device)
        else {
            return false
        }

        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        captureSession.removeInput(currentInput)

        guard captureSession.canAddInput(newInput) else {
            // Giữ camera cũ nếu session không nhận input mới.
            if captureSession.canAddInput(currentInput) {
                captureSession.addInput(currentInput)
            } else {
                videoInput = nil
                isConfigured = false
            }
            return false
        }

        captureSession.addInput(newInput)
        videoInput = newInput
        return true
    }

    func printSessionState() {
        sessionQueue.async { [self] in
            print("isRunning:", captureSession.isRunning)
            print("isInterrupted:", captureSession.isInterrupted)
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
