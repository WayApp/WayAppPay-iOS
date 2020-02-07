//
//  ScannerView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/4/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import AVFoundation
import SwiftUI

protocol HandleScanner {
    func handleScan(result: Result<String, ScannerView.ScanError>)
}

extension HandleScanner {
    func handleScan(result: Result<String, ScannerView.ScanError>) {
       switch result {
       case .success(let code):
            let transaction = WayAppPay.Transaction(amount: WayAppPay.session.amount, token: code)
            print("***********TRANSACTION: \(transaction)")
            transaction.walletPayment()
            print("Success. QR=\(code)")
       case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
       }
    }

}

public struct ScannerView: UIViewControllerRepresentable {

    public enum ScanError: Error {
        case badInput, badOutput
    }
    
    public class ScannerCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: ScannerView
        
        init(parent: ScannerView) {
            assert(parent.simulatedData.isEmpty == false, "The iOS simulator does not support using the camera, so you must set the simulatedData property of ScannerView.")
            self.parent = parent
        }
        
        public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                found(code: stringValue)
            }
        }
        
        func found(code: String) {
            #if targetEnvironment(simulator)
            parent.completion(.success(parent.simulatedData))
            #else
            parent.completion(.success(code))
            #endif
        }
        
        func didFail(reason: ScanError) {
            parent.completion(.failure(reason))
        }
    }
    
    #if targetEnvironment(simulator)
    public class ScannerViewController: UIViewController {
        var delegate: ScannerCoordinator?
        
        override public func loadView() {
            view = UIView()
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            
            label.text = "You're running in the simulator, which means the camera isn't available. Tap anywhere to send back some simulated data."
            
            view.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                label.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
                label.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
            ])
        }
        
        override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            delegate?.found(code: "")
        }
    }
    #else
    public class ScannerViewController: UIViewController {
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
                delegate?.didFail(reason: .badInput)
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()

            if (captureSession.canAddOutput(metadataOutput)) {
                captureSession.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = delegate?.parent.codeTypes
            } else {
                delegate?.didFail(reason: .badOutput)
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
    #endif
    
    public let codeTypes: [AVMetadataObject.ObjectType]
    public var simulatedData = ""
    public var completion: (Result<String, ScanError>) -> Void
    
    public init(codeTypes: [AVMetadataObject.ObjectType], simulatedData: String = "", completion: @escaping (Result<String, ScanError>) -> Void) {
        self.codeTypes = codeTypes
        self.simulatedData = simulatedData
        self.completion = completion
    }
    
    public func makeCoordinator() -> ScannerCoordinator {
        return ScannerCoordinator(parent: self)
    }
    
    public func makeUIViewController(context: Context) -> ScannerViewController {
        let viewController = ScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView(codeTypes: [.qr]) { result in
            // do nothing
        }
    }
}
