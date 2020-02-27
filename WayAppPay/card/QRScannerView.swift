//
//  ScannerView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/4/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import AVFoundation
import SwiftUI

class ScannerCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    @Binding var isShown: Bool
    @Binding var code: String?
    let codeTypes: [AVMetadataObject.ObjectType]
    let completion: () -> Void

    init(isShown : Binding<Bool>, code: Binding<String?>, codeTypes: [AVMetadataObject.ObjectType], completion: @escaping () -> Void) {
        _isShown = isShown
        _code = code
        self.codeTypes = codeTypes
        self.completion = completion
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(scannedCode: stringValue)
        }
    }
    
    func found(scannedCode: String) {
        isShown = false
        code = scannedCode
        completion()
    }
    
    func didFail() {
        isShown = false
        completion()
    }
}

class ScannerViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var delegate: ScannerCoordinator?

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            delegate?.didFail()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = delegate?.codeTypes
        } else {
            delegate?.didFail()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    override public var prefersStatusBarHidden: Bool {
        return true
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

struct CodePicker: UIViewControllerRepresentable {
    @Binding var isShown: Bool
    @Binding var code: String?
    let codeTypes: [AVMetadataObject.ObjectType]
    let completion: () -> Void

    func makeUIViewController(context: UIViewControllerRepresentableContext<CodePicker>) -> ScannerViewController {
        let scanner = ScannerViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: UIViewControllerRepresentableContext<CodePicker>) {
    }

    func makeCoordinator() -> ScannerCoordinator {
        return ScannerCoordinator(isShown: $isShown, code: $code, codeTypes: codeTypes, completion: completion)
    }
}

struct CodeCaptureView: View {
    @Binding var showCodePicker: Bool
    @Binding var code: String?
    let codeTypes: [AVMetadataObject.ObjectType]
    let completion: () -> Void

    var body: some View {
        CodePicker(isShown: $showCodePicker, code: $code, codeTypes: codeTypes, completion: completion)
    }
}

struct CodeCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        CodeCaptureView(showCodePicker: .constant(false), code: .constant(""), codeTypes: [.qr], completion: { })
    }
}
