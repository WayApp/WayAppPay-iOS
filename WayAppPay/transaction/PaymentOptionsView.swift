//
//  PaymentOptionsView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/23/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct PaymentOptionsView: View {
    @EnvironmentObject private var session: WayAppPay.Session

    @State private var showQRScannerForPayment = false
    @State private var showQRScannerForUpdate = false
    @State private var showNFCScannerForPayment = false
    @State private var showNFCScannerForUpdate = false
    @State private var showAlert = false
    @State private var scannedCode: String? = nil
    @State private var wasPaymentSuccessful: Bool = false

    @SwiftUI.Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let rowHeight: CGFloat = 40.0
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .leading, spacing: WayAppPay.UI.verticalSeparation) {
                    Button(action: {
                        self.showQRScannerForPayment = true
                    }, label: {
                        HStack {
                            Image(systemName: "qrcode.viewfinder")
                            .resizable()
                            .frame(width: rowHeight, height: rowHeight, alignment: .center)
                            .aspectRatio(contentMode: .fit)
                            Text("QR")
                        }
                    })
                    .sheet(isPresented: $showQRScannerForPayment) {
                        VStack {
                            CodeCaptureView(showCodePicker: self.$showQRScannerForPayment, code: self.$scannedCode, codeTypes: WayAppPay.acceptedPaymentCodes, completion: self.handleQRScanPayment)
                            HStack {
                                Text("Charge: \(WayAppPay.currencyFormatter.string(for: (self.session.amount))!)")
                                    .foregroundColor(Color.black)
                                    .fontWeight(.medium)
                                Spacer()
                                Button("Done") { self.showQRScannerForPayment = false }
                            }
                            .frame(height: 40.0)
                            .padding()
                            .background(Color.white)
                        }
                    }
                    
                    Button(action: {
                        self.showNFCScannerForPayment = true
                    }, label: {
                        HStack {
                            Image(systemName: "dot.radiowaves.right")
                            .resizable()
                            .frame(width: rowHeight, height: rowHeight, alignment: .center)
                            .aspectRatio(contentMode: .fit)
                            Text("NFC")
                        }
                    })
                    .sheet(isPresented: $showNFCScannerForPayment) {
                        VStack {
                            NFCCodeCaptureView(showCodePicker: self.$showNFCScannerForPayment, code: self.$scannedCode, tagUpdate: nil, completion: self.handleNFCScan)
                            HStack {
                                Text("Charge: \(WayAppPay.currencyFormatter.string(for: (self.session.amount))!)")
                                    .foregroundColor(Color.black)
                                    .fontWeight(.medium)
                                Spacer()
                                Button("Done") { self.showNFCScannerForPayment = false }
                            }
                            .frame(height: 40.0)
                            .padding()
                            .background(Color.white)
                        }
                    }

                    Button(action: {
                        if self.scannedCode != nil {
                            self.showNFCScannerForUpdate = true
                        }
                    }, label: {
                        HStack {
                            Image(systemName: "tag")
                            .resizable()
                            .frame(width: rowHeight, height: rowHeight, alignment: .center)
                            .aspectRatio(contentMode: .fit)
                            Text("Load wearable")
                        }
                    })
                    .sheet(isPresented: $showNFCScannerForUpdate) {
                        VStack {
                            NFCCodeCaptureView(showCodePicker: self.$showNFCScannerForUpdate, code: self.$scannedCode, tagUpdate: String(self.scannedCode!.prefix(3)), completion: self.handleNFCScan)
                            HStack {
                                Text("Charge: \(WayAppPay.currencyFormatter.string(for: (self.session.amount))!)")
                                    .foregroundColor(Color.black)
                                    .fontWeight(.medium)
                                Spacer()
                                Button("Done") { self.showNFCScannerForUpdate = false }
                            }
                            .frame(height: 40.0)
                            .padding()
                            .background(Color.white)
                        }
                    }

                    Button(action: {
                        self.showQRScannerForUpdate = true
                    }, label: {
                        HStack {
                            Image(systemName: "qrcode.viewfinder")
                            .resizable()
                            .frame(width: rowHeight, height: rowHeight, alignment: .center)
                            .aspectRatio(contentMode: .fit)
                            Text("QR")
                        }
                    })
                    .sheet(isPresented: $showQRScannerForUpdate) {
                        VStack {
                            CodeCaptureView(showCodePicker: self.$showQRScannerForUpdate, code: self.$scannedCode, codeTypes: WayAppPay.acceptedPaymentCodes, completion: self.handleQRScanUpdate)
                            HStack {
                                Text("Charge: \(WayAppPay.currencyFormatter.string(for: (self.session.amount))!)")
                                    .foregroundColor(Color.black)
                                    .fontWeight(.medium)
                                Spacer()
                                Button("Done") { self.showQRScannerForUpdate = false }
                            }
                            .frame(height: 40.0)
                            .padding()
                            .background(Color.white)
                        }
                    }

                    Button(action: {
                        self.showNFCScannerForUpdate = false
                    }, label: {
                        HStack {
                            Image(systemName: "creditcard")
                            .resizable()
                            .frame(width: rowHeight, height: rowHeight, alignment: .center)
                            .aspectRatio(contentMode: .fit)
                            Text("Credit card")
                        }
                    })
                } // VStack
                if showAlert {
                    Image(systemName: wasPaymentSuccessful ? WayAppPay.UI.paymentResultSuccessImage : WayAppPay.UI.paymentResultFailureImage)
                        .resizable()
                        .foregroundColor(wasPaymentSuccessful ? Color.green : Color.red)
                        .frame(width: WayAppPay.UI.paymentResultImageSize, height: WayAppPay.UI.paymentResultImageSize, alignment: .center)
                }
            } // ZStack
        } // NavigationView
    } // Body
    
} // Struct

struct PaymentOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentOptionsView()
    }
}

// NFC Payment
extension PaymentOptionsView {
    func handleNFCScan() {
        DispatchQueue.main.async {
            self.wasPaymentSuccessful = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + WayAppPay.UI.paymentResultDisplayDuration) {
            self.presentationMode.wrappedValue.dismiss()
        }

    }
}

// QR Payment
extension PaymentOptionsView {
    func handleQRScanUpdate() {
        if let scannedCode = scannedCode {
            print("Scanned Code: \(scannedCode)")
        }
    }
    
    func handleQRScanPayment() {
        guard let merchantUUID = session.merchantUUID,
            let accountUUID = session.accountUUID,
            let code = scannedCode else {
                WayAppUtils.Log.message("missing session.merchantUUID or session.accountUUID")
                return
        }
        let payment = WayAppPay.PaymentTransaction(amount: Int(session.amount * 100), token: code)
        WayAppPay.API.walletPayment(merchantUUID, accountUUID, payment).fetch(type: [WayAppPay.PaymentTransaction].self) { response in
            self.scannedCode = nil
            if case .success(let response?) = response {
                if let transactions = response.result,
                    let transaction = transactions.first {
                    DispatchQueue.main.async {
                        self.scannedCode = nil
                        self.session.transactions.addAsFirst(transaction)
                        self.wasPaymentSuccessful = (transaction.result == .ACCEPTED)
                        self.session.transactions.addAsFirst(transaction)
                        self.showAlert = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + WayAppPay.UI.paymentResultDisplayDuration) {
                        self.showAlert = false
                        self.presentationMode.wrappedValue.dismiss()
                    }
                } else {
                    self.wasPaymentSuccessful = false
                    self.showAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + WayAppPay.UI.paymentResultDisplayDuration) {
                        self.showAlert = false
                    }
                    WayAppPay.API.reportError(response)
                }
            } else if case .failure(let error) = response {
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }
        
    }
}
