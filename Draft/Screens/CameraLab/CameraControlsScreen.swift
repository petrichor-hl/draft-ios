//
//  CameraControlsScreen.swift
//  Draft
//
//  Phần 6 — Những nút mà app camera thật nào cũng có.
//
//  Sẽ học:
//  - Đổi trước/sau: gỡ input cũ, thêm input mới trong cùng một beginConfiguration().
//  - flashMode vs torchMode.
//  - Zoom: videoZoomFactor và virtual device (ultra-wide / wide / tele nằm chung một device).
//  - lockForConfiguration() / unlockForConfiguration() — dùng khi thay đổi cấu hình AVCaptureDevice.
//  - Tap-to-focus: đổi toạ độ view → toạ độ device bằng captureDevicePointConverted.
//  - AVCaptureDevice.RotationCoordinator (iOS 17+) thay cho việc tự nghe xoay máy.
//

import SwiftUI
import AVFoundation

struct CameraControlsScreen: View {
    
    @State private var camera = CameraSessionController()
    @State private var isPreviewVisible = false
    
    @State private var selectedZoom: Double = 1.0
    @State private var selectedFlashMode: AVCaptureDevice.FlashMode = .off
    @State private var isTorchEnabled = false
    @State private var isChangingTorch = false
    @State private var showsTorchError = false
    @State private var isSwitchingCamera = false
    
    private let zoomLevels = [1.0, 1.5, 2.0, 3.0]
    private var selectedIndex: Int {
        zoomLevels.firstIndex(of: selectedZoom) ?? 0
    }
    
    @State private var focusPoint: CGPoint?
    @State private var focusAnimationTriggerId = UUID()
    @State private var isFocusFrameVisible = false
    
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
                    .frame(maxWidth: .infinity)
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
                CameraPreview(session: camera.captureSession) { viewPoint, devicePoint in
                    guard !isSwitchingCamera else { return }
                    
                    focusPoint = viewPoint
                    focusAnimationTriggerId = UUID()
                    isFocusFrameVisible = true
                    camera.focus(at: devicePoint)
                }
                .overlay {
                    focusFrame
                }
                .ignoresSafeArea()
                
                VStack {
                    HStack {
                        flashButton
                        torchButton
                        Spacer()
                        closeButton
                    }
                    
                    Spacer()
                    
                    zoomSelector
                        .disabled(isSwitchingCamera)
                        .padding(.bottom, 16)
                    
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
                
                focusPoint = nil
                isFocusFrameVisible = false
                
                selectedFlashMode = .off
                isTorchEnabled = false
            }
            .alert("Unable to change torch", isPresented: $showsTorchError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("The torch may be unavailable on this camera.")
            }
        }
        .navigationTitle("6. Điều khiển")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var focusFrame: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(
                .yellow,
                style: StrokeStyle(lineWidth: 2, dash: [24, 8])
            )
            .frame(width: 80, height: 80)
            .keyframeAnimator(
                initialValue: CGFloat(1),
                trigger: focusAnimationTriggerId
            ) { content, scale in
                content.scaleEffect(scale)
            } keyframes: { _ in
                MoveKeyframe(1.5)
                CubicKeyframe(1, duration: 0.25)
            }
            .position(focusPoint ?? .zero)
            .opacity(isFocusFrameVisible ? 1 : 0)
            .task(id: focusAnimationTriggerId) {
                guard focusPoint != nil else { return }
                
                try? await Task.sleep(for: .seconds(3))
                guard !Task.isCancelled else { return }
                
                withAnimation(.easeOut(duration: 0.4)) {
                    isFocusFrameVisible = false
                }
            }
    }
    
    private var captureButton: some View {
        Button {
            camera.capturePhoto(flashMode: selectedFlashMode)
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
        .disabled(isSwitchingCamera || isChangingTorch)
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
    
    private var flashButton: some View {
        Button {
            switch selectedFlashMode {
            case .off:
                selectedFlashMode = .on
            case .on:
                selectedFlashMode = .auto
            case .auto:
                selectedFlashMode = .off
            @unknown default:
                selectedFlashMode = .off
            }
        } label: {
            HStack {
                Image(systemName: flashPresentation.symbol)
                    .font(.system(size: 18))
                Text(flashPresentation.title)
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(selectedFlashMode == .off ? Color.white : Color.yellow)
            .frame(width: 80, height: 44)
            .background(.black.opacity(0.35), in: .capsule)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Flash")
        .accessibilityValue(Text(flashPresentation.title))
    }
    
    private var flashPresentation: (symbol: String, title: LocalizedStringKey) {
        switch selectedFlashMode {
        case .off:
            return ("bolt.slash.fill", "Off")
        case .on:
            return ("bolt.fill", "On")
        case .auto:
            return ("bolt.badge.a.fill", "Auto")
        @unknown default:
            return ("bolt.slash.fill", "Off")
        }
    }
    
    private var torchButton: some View {
        Button {
            isChangingTorch = true
            let shouldEnable = !isTorchEnabled
            
            Task {
                defer { isChangingTorch = false }
                
                let succeeded = await camera.setTorchEnabled(shouldEnable)
                guard isPreviewVisible else { return }
                
                if succeeded {
                    isTorchEnabled = shouldEnable
                } else {
                    showsTorchError = true
                }
            }
        } label: {
            Image(systemName: isTorchEnabled ? "flashlight.on.fill" : "flashlight.off.fill")
                .font(.title3)
                .foregroundStyle(isTorchEnabled ? Color.yellow : Color.white)
                .frame(width: 44, height: 44)
                .background(.black.opacity(0.35), in: .circle)
        }
        .buttonStyle(.plain)
        .disabled(isChangingTorch || isSwitchingCamera)
    }
    
    private var switchCameraButton: some View {
        Button {
            isSwitchingCamera = true
            
            Task {
                defer { isSwitchingCamera = false }
                
                if isTorchEnabled {
                    guard await camera.setTorchEnabled(false) else {
                        showsTorchError = true
                        return
                    }
                    isTorchEnabled = false
                }
                
                if await camera.switchCamera() {
                    selectedZoom = 1.0
                    focusPoint = nil
                    isFocusFrameVisible = false
                }
            }
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.black.opacity(0.35), in: .circle)
        }
        .buttonStyle(.plain)
        .disabled(isSwitchingCamera || isChangingTorch)
        .accessibilityLabel("Switch camera")
    }
    
    private var zoomSelector: some View {
        let segmentWidth: CGFloat = 60
        
        return ZStack(alignment: .leading) {
            Capsule()
                .fill(.white)
                .frame(width: segmentWidth, height: 38)
                .offset(x: CGFloat(selectedIndex) * segmentWidth)
                .animation(.snappy(duration: 0.25), value: selectedZoom)
                .allowsHitTesting(false)
            
            HStack(spacing: 0) {
                ForEach(zoomLevels, id: \.self) { zoom in
                    Button {
                        guard selectedZoom != zoom else { return }
                        camera.setZoom(CGFloat(zoom))
                        selectedZoom = zoom
                    } label: {
                        Text("\(zoom, format: .number.precision(.fractionLength(0...1)))x")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(
                                selectedZoom == zoom
                                ? Color.black
                                : Color.white.opacity(0.6)
                            )
                            .frame(width: segmentWidth, height: 38)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(3)
        .background(.black.opacity(0.35), in: .capsule)
    }
}
