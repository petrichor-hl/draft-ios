//
//  UIKitCameraPresentationScreen.swift
//  Draft
//
//  Phần 3 — UIKit present CameraView với .overFullScreen, start sau khi animation hoàn tất.
//  - UIViewControllerRepresentable đưa UIKit presenter vào màn SwiftUI.
//  - UIHostingController chứa CameraView viết bằng SwiftUI.
//  - Completion của present chạy sau presentation và viewDidAppear.
//  - .overFullScreen giữ các view phía dưới trong hierarchy.
//

import SwiftUI
import UIKit

struct UIKitCameraPresentationScreen: View {
    var body: some View {
        CameraPresenter()
            .navigationTitle("3. UIKit Presentation")
            .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CameraPresenter: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraPresentationViewController {
        CameraPresentationViewController()
    }
    
    func updateUIViewController(_ uiViewController: CameraPresentationViewController, context: Context) {}
    
    static func dismantleUIViewController(_ uiViewController: CameraPresentationViewController, coordinator: ()) {
        uiViewController.tearDown()
    }
}

private final class CameraPresentationViewController: UIViewController {
    private let camera = CameraSessionController()
    private var cameraController: UIHostingController<CameraView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        var openConfiguration = UIButton.Configuration.filled()
        openConfiguration.title = String(localized: "Open camera")
        openConfiguration.image = UIImage(systemName: "camera")
        openConfiguration.imagePadding = 8
        openConfiguration.buttonSize = .large
        
        let openButton = UIButton(configuration: openConfiguration)
        openButton.addAction(UIAction { [weak self] _ in
            self?.presentCamera()
        }, for: .touchUpInside)
        
        var stateConfiguration = UIButton.Configuration.bordered()
        stateConfiguration.title = String(localized: "Print session state")
        let stateButton = UIButton(configuration: stateConfiguration)
        stateButton.addAction(UIAction { [weak self] _ in
            self?.camera.printSessionState()
        }, for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [openButton, stateButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func presentCamera() {
        guard cameraController == nil, view.window != nil else { return }
        
        let controller = UIHostingController(rootView: CameraView(camera: camera) { [weak self] in
            self?.dismissCamera()
        })
        controller.modalPresentationStyle = .overFullScreen
        controller.view.backgroundColor = .black
        cameraController = controller
        
        print("Presenting CameraView")
        present(controller, animated: true) { [weak self, weak controller] in
            guard
                let self, let controller,
                self.cameraController === controller,
                controller.presentingViewController != nil,
                !controller.isBeingDismissed
            else { return }
            
            // Animation mở đã hoàn tất. start() vẫn thực hiện startRunning trên sessionQueue.
            print("Presentation finished — requesting camera.start()")
            self.camera.start()
        }
    }
    
    private func dismissCamera() {
        guard let controller = cameraController, !controller.isBeingDismissed else { return }
        let camera = camera
        
        controller.dismiss(animated: true) { [weak self] in
            print("Dismissal finished — requesting camera.stop()")
            camera.stop()
            self?.cameraController = nil
        }
    }
    
    func tearDown() {
        camera.stop()
        cameraController?.dismiss(animated: false)
        cameraController = nil
    }
}

private struct CameraView: View {
    let camera: CameraSessionController
    let onClose: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            CameraPreview(session: camera.captureSession)
                .ignoresSafeArea()
            
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.headline)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial, in: .circle)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close camera")
            .padding()
        }
        .background(.black)
        .onAppear {
            // SwiftUI onAppear không phải tín hiệu animation UIKit đã hoàn tất.
            print("CameraView.onAppear")
        }
    }
}
