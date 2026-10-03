//
//  CameraSessionController.swift
//  Draft
//
//  Điều khiển capture session trên serial queue.
//

import AVFoundation
import Dispatch

// @unchecked Sendable means we take responsibility for synchronization ourselves.
nonisolated final class CameraSessionController: NSObject, AVCapturePhotoCaptureDelegate, @unchecked Sendable {
    var onPhotoCaptured: ((Data) -> Void)?
    
    let captureSession = AVCaptureSession()
    
    private var isConfigured = false
    private let photoCaptureOutput = AVCapturePhotoOutput()
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    
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
            captureSession.canAddInput(videoDeviceInput),
            captureSession.canAddOutput(photoCaptureOutput)
                else {
            return false
        }
        
        captureSession.addInput(videoDeviceInput)
        captureSession.addOutput(photoCaptureOutput)
        
        rotationCoordinator = AVCaptureDevice.RotationCoordinator(
            device: videoDevice,
            previewLayer: nil
        )
        
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
    
    func capturePhoto() {
        sessionQueue.async { [self] in
            guard captureSession.isRunning else {
                print("Camera session is not running.")
                return
            }
            
            guard
                let rotationCoordinator,
                let connection = photoCaptureOutput.connection(with: .video)
                    else {
                print("Unable to configure photo rotation.")
                return
            }
            
            let angle = rotationCoordinator.videoRotationAngleForHorizonLevelCapture
            
            guard connection.isVideoRotationAngleSupported(angle) else {
                print("Unsupported rotation angle:", angle)
                return
            }
            
            connection.videoRotationAngle = angle
            connection.isVideoMirrored = rotationCoordinator.device?.position == .front
            
            photoCaptureOutput.capturePhoto(
                with: AVCapturePhotoSettings(),
                delegate: self
            )
        }
    }
    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            print("Unable to capture photo:", error)
            return
        }
        
        guard let data = photo.fileDataRepresentation() else {
            print("Unable to create photo data.")
            return
        }
        
        self.onPhotoCaptured?(data)
    }
    
    func stop() {
        sessionQueue.async { [self] in
            if let device = captureSession.inputs
                .compactMap({ $0 as? AVCaptureDeviceInput })
                .first(where: { $0.device.hasMediaType(.video) })?.device,
               device.hasTorch {
                do {
                    _ = try configureTorch(false, on: device)
                } catch {
                    print("Unable to turn off torch:", error)
                }
            }
            
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
    
    func setZoom(_ factor: CGFloat) {
        sessionQueue.async { [self] in
            guard let videoDeviceInput = captureSession.inputs
                .compactMap({ $0 as? AVCaptureDeviceInput })
                .first(where: { $0.device.hasMediaType(.video) })
                    else {
                return
            }
            
            let device: AVCaptureDevice = videoDeviceInput.device
            
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                
                guard factor >= device.minAvailableVideoZoomFactor,
                      factor <= device.maxAvailableVideoZoomFactor
                        else {
                    print("Unsupported zoom factor:", factor)
                    return
                }
                
                device.ramp(
                    toVideoZoomFactor: factor,
                    withRate: 2
                )
            } catch {
                print("Unable to configure zoom:", error)
            }
        }
    }
    
    func setTorchEnabled(_ enabled: Bool) async -> Bool {
        await withCheckedContinuation { continuation in
            sessionQueue.async { [self] in
                guard let device = captureSession.inputs
                    .compactMap({ $0 as? AVCaptureDeviceInput })
                    .first(where: { $0.device.hasMediaType(.video) })?.device
                        else {
                    continuation.resume(returning: false)
                    return
                }
                
                do {
                    let succeeded = try configureTorch(enabled, on: device)
                    continuation.resume(returning: succeeded)
                } catch {
                    print("Unable to configure torch:", error)
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    // Called only on sessionQueue, including when stopping the session.
    private func configureTorch(_ enabled: Bool, on device: AVCaptureDevice) throws -> Bool {
        let mode: AVCaptureDevice.TorchMode = enabled ? .on : .off
        
        guard device.hasTorch, device.isTorchModeSupported(mode) else {
            return false
        }
        
        try device.lockForConfiguration()
        defer { device.unlockForConfiguration() }
        
        guard !enabled || device.isTorchAvailable else {
            return false
        }
        
        device.torchMode = mode
        return true
    }
    
    @discardableResult
    func switchCamera() async -> Bool {
        await withCheckedContinuation { continuation in
            sessionQueue.async { [self] in
                guard let currentInput = captureSession.inputs
                    .compactMap({ $0 as? AVCaptureDeviceInput })
                    .first(where: { $0.device.hasMediaType(.video) })
                        else {
                    continuation.resume(returning: false)
                    return
                }
                
                let position: AVCaptureDevice.Position =
                currentInput.device.position == .back ? .front : .back
                
                guard let device = AVCaptureDevice.default(
                    .builtInWideAngleCamera,
                    for: .video,
                    position: position
                ) else {
                    print("Requested camera is unavailable.")
                    continuation.resume(returning: false)
                    return
                }
                
                do {
                    let newInput = try AVCaptureDeviceInput(device: device)
                    
                    // Reset zoom so the new camera and the selector both start at 1x.
                    try device.lockForConfiguration()
                    device.videoZoomFactor = 1
                    device.unlockForConfiguration()
                    
                    captureSession.beginConfiguration()
                    captureSession.removeInput(currentInput)
                    
                    let canSwitch = captureSession.canAddInput(newInput)
                    if canSwitch {
                        captureSession.addInput(newInput)
                        rotationCoordinator = AVCaptureDevice.RotationCoordinator(
                            device: device,
                            previewLayer: nil
                        )
                    } else {
                        // Keep the preview working if the new input is rejected.
                        captureSession.addInput(currentInput)
                        print("Unable to add the new camera input.")
                    }
                    
                    captureSession.commitConfiguration()
                    continuation.resume(returning: canSwitch)
                } catch {
                    print("Unable to switch camera:", error)
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    func printSessionState() {
        sessionQueue.async { [self] in
            print("isRunning:", captureSession.isRunning)
            print("isInterrupted:", captureSession.isInterrupted)
        }
    }
}
