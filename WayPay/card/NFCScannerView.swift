//
//  NFCScannerView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/23/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI
#if canImport(CoreNFC)
import CoreNFC
#endif
import AVFoundation

class NFCScannerCoordinator: NSObject  {

    @Binding var isShown: Bool
    @Binding var code: String?
    let tagUpdate: String?
    let completion: () -> Void
    
    init(isShown : Binding<Bool>, code: Binding<String?>, tagUpdate: String?, completion: @escaping () -> Void) {
        _isShown = isShown
        _code = code
        self.tagUpdate = tagUpdate
        self.completion = completion
    }
        
    var isPaymentTransaction: Bool {
        return tagUpdate == nil
    }
    
    var isUpdateTransaction: Bool {
        return tagUpdate != nil
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

#if canImport(CoreNFC)
class NFCScannerViewController: UIViewController {
    var message: NFCNDEFMessage = .init(records: [])
    var session: NFCNDEFReaderSession?
    var delegate: NFCScannerCoordinator?

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        beginScanning()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

    override public var prefersStatusBarHidden: Bool {
        return true
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func beginScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
                let alertController = UIAlertController(
                    title: "Scanning Not Supported",
                    message: "This device doesn't support tag scanning.",
                    preferredStyle: .alert
                )
                let dismissAction = UIAlertAction(title: WayPay.SingleMessage.OK.text, style: .default) {_ in
                    self.delegate?.didFail()
                }
                alertController.addAction(dismissAction)
                self.present(alertController, animated: true, completion: nil)
                return
        }
        assert(delegate != nil, "Missing NFCScannerViewController delegate")
        session = NFCNDEFReaderSession(delegate: delegate!, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Hold your iPhone near the item to learn more about it."
        session?.begin()
    }

}

struct NFCCodePicker: UIViewControllerRepresentable {
    @Binding var isShown: Bool
    @Binding var code: String?
    let tagUpdate: String?
    let completion: () -> Void

    func makeUIViewController(context: UIViewControllerRepresentableContext<NFCCodePicker>) -> NFCScannerViewController {
        let scanner = NFCScannerViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: NFCScannerViewController, context: UIViewControllerRepresentableContext<NFCCodePicker>) {
    }

    func makeCoordinator() -> NFCScannerCoordinator {
        return NFCScannerCoordinator(isShown: $isShown, code: $code, tagUpdate: tagUpdate, completion: completion)
    }
}

struct NFCCodeCaptureView: View {
    @Binding var showCodePicker: Bool
    @Binding var code: String?
    let tagUpdate: String?
    let completion: () -> Void

    var body: some View {
        NFCCodePicker(isShown: $showCodePicker, code: $code, tagUpdate: tagUpdate, completion: completion)
    }
}

struct NFCCodeCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        NFCCodeCaptureView(showCodePicker: .constant(false), code: .constant(""), tagUpdate: nil, completion: { })
    }
}

extension NFCScannerCoordinator: NFCNDEFReaderSessionDelegate {
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        WayAppUtils.Log.message("****** CANCEL: didInvalidateWithError")
        didFail()

                // Check the invalidation reason from the returned error.
        /*
        if let readerError = error as? NFCReaderError {
            // Show an alert when the invalidation reason is not because of a success read
            // during a single tag read mode, or user canceled a multi-tag read mode session
            // from the UI or programmatically using the invalidate method call.
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                didFail()
            }
        }
 */

    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            // Restart polling in 500ms
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 tag is detected, please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }
        
        // Connect to the found tag and perform NDEF message reading
        let tag = tags.first!
        session.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = "Unable to connect to tag."
                session.invalidate()
                self.didFail()
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                if .notSupported == ndefStatus {
                    session.alertMessage = "Tag is not NDEF compliant"
                    session.invalidate()
                    self.didFail()
                    return
                } else if nil != error {
                    session.alertMessage = "Unable to query NDEF status of tag"
                    session.invalidate()
                    self.didFail()
                    return
                }
                
                if self.isPaymentTransaction {
                    tag.readNDEF(completionHandler: { (message: NFCNDEFMessage?, error: Error?) in
                        if error == nil,
                            let message = message,
                            let readMessage = self.readMessage(message) {
                            session.alertMessage = "Found 1 NDEF message"
                            WayAppUtils.Log.message("TAG=\(readMessage)")
                            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                            session.invalidate()
                            self.found(scannedCode: readMessage)
                        } else {
                            session.alertMessage = "Fail to read NDEF from tag"
                            session.invalidate()
                            self.didFail()
                        }
                    })
                } else if self.isUpdateTransaction {
                    if ndefStatus == .readWrite {
                        let wapPayload = NFCNDEFPayload.wellKnownTypeURIPayload(string: self.tagUpdate!)
                        let ndefMessage = NFCNDEFMessage(records: [wapPayload!])
                        tag.writeNDEF(ndefMessage, completionHandler: { (error: Error?) in
                            if nil != error {
                                session.alertMessage = "Write NDEF message fail: \(error!)"
                            } else {
                                session.alertMessage = "Write NDEF message successful."
                            }
                            session.invalidate()
                            self.found(scannedCode: self.tagUpdate!)
                        })
                    } else {
                        session.alertMessage = "Tag is read only."
                        session.invalidate()
                        self.didFail()
                    }
                } else {
                    session.alertMessage = "Unrecognized operation."
                    session.invalidate()
                    self.didFail()
                }
            })
        })
    }
        
    private func readMessage(_ message: NFCNDEFMessage) -> String? {
        guard !message.records.isEmpty else {
            WayAppUtils.Log.message("message.records.isEmpty")
            return nil
        }
        let payload = message.records[0]
        switch payload.typeNameFormat {
        case .nfcWellKnown:
            if let url = payload.wellKnownTypeURIPayload() {
                return "\(url.absoluteString)"
            } else {
                let (text, _) = payload.wellKnownTypeTextPayload()
                if let text = text {
                    return "\(text)"
                }
            }
        case .absoluteURI:
            if let text = String(data: payload.payload, encoding: .utf8) {
                return text
            }
        case .media, .nfcExternal, .empty, .unknown, .unchanged:
            fallthrough
        @unknown default:
            return nil
        }
        return nil
    }

}
#endif
