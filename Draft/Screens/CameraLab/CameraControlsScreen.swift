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

struct CameraControlsScreen: View {

    @State private var camera = CameraSessionController()
    @State private var isPreviewVisible = false

    @State private var selectedZoom: Double = 1.0
    @State private var isFlashEnabled = false
    @State private var isTorchEnabled = false
    @State private var isChangingTorch = false
    @State private var showsTorchError = false
    @State private var isSwitchingCamera = false

    private let zoomLevels = [1.0, 1.5, 2.0, 3.0]
    private var selectedIndex: Int {
        zoomLevels.firstIndex(of: selectedZoom) ?? 0
    }

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
            ZStack() {
                CameraPreview(session: camera.captureSession)
                    .ignoresSafeArea()

                VStack {
                    HStack {
                        flashButton
                        torchButton
                        Spacer()
                        closeButton
                    }

                    Spacer()

                    HStack {
                        galleryButton
                        Spacer()
                        zoomSelector
                            .disabled(isSwitchingCamera)
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
            isFlashEnabled.toggle()
        } label: {
            Image(systemName: isFlashEnabled ? "bolt.fill" : "bolt.slash.fill")
                .font(.title3)
                .foregroundStyle(isFlashEnabled ? Color.yellow : Color.white)
                .frame(width: 44, height: 44)
                .background(.black.opacity(0.35), in: .circle)
        }
        .buttonStyle(.plain)
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
