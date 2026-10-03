//
//  CameraControlsScreen.swift
//  Draft
//
//  Phần 6 — Những nút mà app camera thật nào cũng có.
//
//  Sẽ học:
//  - Đổi trước/sau: gỡ input cũ, thêm input mới trong cùng một beginConfiguration().
//  - flashMode (lúc chụp) khác torchMode (đèn pin bật liên tục).
//  - Zoom: videoZoomFactor và virtual device (ultra-wide / wide / tele nằm chung một device).
//  - lockForConfiguration() / unlockForConfiguration() — mọi thay đổi trên device đều cần.
//  - Tap-to-focus: đổi toạ độ view → toạ độ device bằng captureDevicePointConverted.
//  - AVCaptureDevice.RotationCoordinator (iOS 17+) thay cho việc tự nghe xoay máy.
//

import SwiftUI

struct CameraControlsScreen: View {

    @State private var camera = CameraSessionController()
    @State private var isPreviewVisible = false

    @State private var selectedZoom: Double = 1.0

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
                    closeButton
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    Spacer()

                    zoomSelector
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
