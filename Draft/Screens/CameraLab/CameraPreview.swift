//
//  CameraPreview.swift
//  Draft
//
//  Created by Trần Lê Hoàng Lâm on 4/10/26.
//


import SwiftUI
import AVFoundation

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
    var onTap: ((CGPoint, CGPoint) -> Void)? = nil
    
    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill

        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        tap.isEnabled = onTap != nil
        view.addGestureRecognizer(tap)
        return view
    }
    
    func updateUIView(
        _ uiView: CameraPreviewView,
        context: Context
    ) {
        context.coordinator.onTap = onTap
        uiView.gestureRecognizers?
            .first(where: { $0 is UITapGestureRecognizer })?
            .isEnabled = onTap != nil
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }

    final class Coordinator: NSObject {
        var onTap: ((CGPoint, CGPoint) -> Void)?

        init(onTap: ((CGPoint, CGPoint) -> Void)?) {
            self.onTap = onTap
        }

        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let view = recognizer.view as? CameraPreviewView,
                  recognizer.state == .ended,
                  view.previewLayer.connection != nil
            else { return }

            let viewPoint = recognizer.location(in: view)
            guard view.bounds.contains(viewPoint) else { return }

            // Let the layer account for cropping, rotation, and mirroring.
            let devicePoint = view.previewLayer.captureDevicePointConverted(
                fromLayerPoint: viewPoint
            )
            onTap?(viewPoint, devicePoint)
        }
    }
}
