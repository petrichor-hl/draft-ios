//
//  DietfitCameraScreen.swift
//  Draft
//
//  Ví dụ thực tế — tham khảo trải nghiệm camera của Dietfit.
//

import SwiftUI

struct DietfitCameraScreen: View {
    @State private var camera = CameraSessionController()
    @State private var isPreviewVisible = false

    @State private var selectedZoom: Double = 1.0
    @State private var isChangingZoom = false
    @State private var isZoomChangeFailed = false

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
            ZStack {
                CameraPreview(session: camera.captureSession)
                    .ignoresSafeArea()


                VStack {
                    HStack {
                        Button {
                            isPreviewVisible = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.headline)
                                .frame(width: 44, height: 44)
                                .background(.regularMaterial, in: .circle)
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        zoomSelector

                        Spacer()

                        Button {

                        } label: {
                            Image(systemName: "questionmark")
                                .font(.headline)
                                .frame(width: 44, height: 44)
                                .background(.regularMaterial, in: .circle)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    HStack {

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
            .alert("Không thể đổi camera", isPresented: $isZoomChangeFailed) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Hãy kiểm tra quyền camera và thử lại.")
            }
        }
        .navigationTitle("Dietfit")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var zoomSelector: some View {
        let segmentWidth: CGFloat = 48

        return ZStack(alignment: .leading) {
            Capsule()
                .fill(.white)
                .frame(width: segmentWidth, height: 38)
                .offset(x: selectedZoom == 0.5 ? 0 : segmentWidth)
                .animation(.snappy(duration: 0.25), value: selectedZoom)
                .allowsHitTesting(false)

            HStack(spacing: 0) {
                ForEach([0.5, 1.0], id: \.self) { zoom in
                    Button {
                        guard selectedZoom != zoom else { return }
                        isChangingZoom = true
                        Task {
                            if await camera.changeZoom(zoom) {
                                selectedZoom = zoom
                            } else {
                                isZoomChangeFailed = true
                            }
                            isChangingZoom = false
                        }
                    } label: {
                        Text(zoom == 0.5 ? "0.5x" : "1x")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(
                                selectedZoom == zoom
                                    ? Color.black
                                    : Color.white.opacity(0.6)
                            )
                            .frame(width: segmentWidth, height: 38)
                            .contentShape(.capsule)
                    }
                    .buttonStyle(.plain)
                    .disabled(isChangingZoom || (zoom == 0.5 && !camera.supportsUltraWide))
                    .opacity(zoom == 0.5 && !camera.supportsUltraWide ? 0.4 : 1)
                }
            }
        }
        .padding(3)
        .background(.black.opacity(0.35), in: .capsule)
    }
}
