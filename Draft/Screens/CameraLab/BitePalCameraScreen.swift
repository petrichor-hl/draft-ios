//
//  BitePalCameraScreen.swift
//  Draft
//
//  Ví dụ thực tế — tham khảo trải nghiệm camera của BitePal.
//

import SwiftUI

struct BitePalCameraScreen: View {

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
            .onDisappear {
                camera.stop()
            }
        }
        .navigationTitle("BitePal")
        .navigationBarTitleDisplayMode(.inline)
    }
}
