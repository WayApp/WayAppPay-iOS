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
    @State private var showCheckinScanner = false
    
    var topupAmount: Double = 0
    
    @SwiftUI.Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let rowHeight: CGFloat = 60.0
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section(header: Text("QR").font(.headline)) {
                        if !WayAppPay.session.shoppingCart.isEmpty {
                            Button(action: {
                                self.showQRScannerForPayment = true
                            }, label: {
                                HStack {
                                    Image(systemName: "qrcode.viewfinder")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30, alignment: .leading)
                                    Text("Charge")
                                }
                            })
                            .sheet(isPresented: $showQRScannerForPayment) {
                                VStack {
                                    CodeCaptureView(showCodePicker: self.$showQRScannerForPayment, code: self.$scannedCode, codeTypes: WayAppPay.acceptedPaymentCodes, completion: self.handleQRScanPayment)
                                    HStack {
                                        Text("Charge: \(WayAppPay.formatPrice(self.session.amount))")
                                            .foregroundColor(Color.black)
                                            .fontWeight(.medium)
                                        Spacer()
                                        Button("Done") { self.showQRScannerForPayment = false }
                                    }
                                    .frame(height: 40.0)
                                    .padding()
                                    .background(Color.white)
                                }
                            } // sheet
                        }
                        //if (topupAmount > 0) {
                        /*
                        if (false) {
                            Button(action: {
                                self.showQRScannerForPayment = true
                            }, label: {
                                HStack {
                                    Image(systemName: "plus.square")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30, alignment: .leading)
                                    Text("Top-up: \(WayAppPay.currencyFormatter.string(for: topupAmount / 100)!)")
                                }
                            })
                            .sheet(isPresented: $showQRScannerForPayment) {
                                VStack {
                                    CodeCaptureView(showCodePicker: self.$showQRScannerForPayment, code: self.$scannedCode, codeTypes: WayAppPay.acceptedPaymentCodes, completion: self.handleTopup)
                                    HStack {
                                        Text("Top-up: \(WayAppPay.currencyFormatter.string(for: topupAmount / 100)!)")
                                            .foregroundColor(Color.black)
                                            .fontWeight(.medium)
                                        Spacer()
                                        Button("Done") { self.showQRScannerForPayment = false }
                                    }
                                    .frame(height: 40.0)
                                    .padding()
                                    .background(Color.white)
                                }
                            } // sheet
                        }
 */
                        /*
                        Button(action: {
                            self.showCheckinScanner = true
                        }, label: {
                            HStack {
                                Image(systemName: "checkmark.rectangle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30, alignment: .leading)
                                Text("Check-in")
                            }
                        })
                        .sheet(isPresented: $showCheckinScanner) {
                            VStack {
                                CodeCaptureView(showCodePicker: self.$showCheckinScanner, code: self.$scannedCode, codeTypes: WayAppPay.acceptedPaymentCodes, completion: self.getCheckins)
                                HStack {
                                    Text("Check-in")
                                        .foregroundColor(Color.black)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Button("Done") { self.showCheckinScanner = false }
                                }
                                .frame(height: 40.0)
                                .padding()
                                .background(Color.white)
                            } // vstack
                        } // sheet
 */
                    } // Section
                    /*
                    /* testing Commit/Push */
                    Section(header: Text("NFC").font(.headline)) {
                        if !WayAppPay.session.shoppingCart.isEmpty {
                            Button(action: {
                                self.showNFCScannerForPayment = true
                            }, label: {
                                HStack {
                                    Image(systemName: "dot.radiowaves.right")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30, alignment: .leading)
                                    Text("Payment")
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
                            } // sheet
                        }
                        Button(action: {
                            self.showQRScannerForUpdate = true
                        }, label: {
                            HStack {
                                Image(systemName: "camera")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30, alignment: .leading)
                                Text("Read token")
                            }
                        })
                        .sheet(isPresented: $showQRScannerForUpdate) {
                            VStack {
                                CodeCaptureView(showCodePicker: self.$showQRScannerForUpdate, code: self.$scannedCode, codeTypes: WayAppPay.acceptedPaymentCodes, completion: self.handleQRScanUpdate)
                                HStack {
                                    Text("Read token")
                                        .foregroundColor(Color.black)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Button("Done") { self.showQRScannerForUpdate = false }
                                }
                                .frame(height: 40.0)
                                .padding()
                                .background(Color.white)
                            }
                        } // sheet
                        Button(action: {
                            if self.scannedCode != nil {
                                self.showNFCScannerForUpdate = true
                            }
                        }, label: {
                            HStack {
                                Image(systemName: "square.and.pencil")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30, alignment: .leading)
                                Text("Write token")
                            }
                        })
                        .sheet(isPresented: $showNFCScannerForUpdate) {
                            VStack {
                                NFCCodeCaptureView(showCodePicker: self.$showNFCScannerForUpdate, code: self.$scannedCode, tagUpdate: self.scannedCode!, completion: self.handleQRScanUpdate)
                                HStack {
                                    Text("Write token")
                                        .foregroundColor(Color.black)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Button("Done") { self.showNFCScannerForUpdate = false }
                                }
                                .frame(height: 40.0)
                                .padding()
                                .background(Color.white)
                            } // vstack
                        } // sheet
                    } // Section
 */
                } // Form
                if showAlert {
                    Image(systemName: wasPaymentSuccessful ? WayAppPay.UI.paymentResultSuccessImage : WayAppPay.UI.paymentResultFailureImage)
                        .resizable()
                        .foregroundColor(wasPaymentSuccessful ? Color.green : Color.red)
                        .frame(width: WayAppPay.UI.paymentResultImageSize, height: WayAppPay.UI.paymentResultImageSize, alignment: .center)
                }
            } // ZStack
            .foregroundColor(.primary)
            .navigationBarTitle("Operation", displayMode: .inline)
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
    func handleTopup() {
        WayAppUtils.Log.message("Topping up: \(topupAmount)")
        guard let code = scannedCode else {
            WayAppUtils.Log.message("Missing session.merchantUUID or session.accountUUID")
            return
        }
        let topup = WayAppPay.PaymentTransaction(amount: Int(topupAmount), token: code, type: .ADD)
        WayAppPay.API.topup(topup).fetch(type: [WayAppPay.PaymentTransaction].self) { response in
            self.scannedCode = nil
            if case .success(let response?) = response {
                if let transactions = response.result,
                   let transaction = transactions.first {
                    DispatchQueue.main.async {
                        self.scannedCode = nil
                        self.session.transactions.addAsFirst(transaction)
                        self.wasPaymentSuccessful = (transaction.result == .ACCEPTED)
                        self.showAlert = true
                        WayAppPay.session.shoppingCart.empty()
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
    
    func handleNFCScan() {
        WayAppUtils.Log.message("Scanned NFC Tag: \(scannedCode ?? "no scanned code")")
        handleQRScanPayment()
    }
    
    func handleCheckin() {
        WayAppUtils.Log.message("handleCheckin: ENTERING with scannedCode=\(scannedCode ?? "no scanned code")")
        guard let scannedCode = scannedCode else {
            WayAppUtils.Log.message("handleCheckin: no scanned code")
            return
        }
        WayAppPay.WalletAPI.postCheckin(scannedCode).fetch(type: [WayAppPay.Checkin].self) { response in
            if case .success(let response?) = response {
                WayAppUtils.Log.message("handleCheckin: SUCCESS with response=\(response)")
            } else if case .failure(let error) = response {
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }
    }
    
    func getCheckins() {
        WayAppUtils.Log.message("getCheckins: ENTERING with scannedCode=\(scannedCode ?? "no scanned code")")
        guard let scannedCode = scannedCode else {
            WayAppUtils.Log.message("getCheckins: no scanned code")
            return
        }
        WayAppPay.WalletAPI.getCheckins(scannedCode).fetch(type: [WayAppPay.CheckinRecord].self) { response in
            if case .success(let response?) = response {
                WayAppUtils.Log.message("getCheckins: SUCCESS with response=\(response)")
            } else if case .failure(let error) = response {
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }
    }
    
}

// QR Payment
extension PaymentOptionsView {
    
    func handleQRScanUpdate() {
        WayAppUtils.Log.message("Scanned NFC Tag: \(scannedCode ?? "no scaneed code")")
    }
    
    func handleQRScanPayment() {
        guard let merchantUUID = session.merchantUUID,
              let accountUUID = session.accountUUID,
              let code = scannedCode else {
            WayAppUtils.Log.message("Missing session.merchantUUID or session.accountUUID")
            return
        }
        let payment = WayAppPay.PaymentTransaction(amount: session.amount, purchaseDetail: session.shoppingCart.arrayOfCartItems, token: code)
        WayAppUtils.Log.message("++++++++++ WayAppPay.PaymentTransaction: \(payment)")
        WayAppPay.API.walletPayment(merchantUUID, accountUUID, payment).fetch(type: [WayAppPay.PaymentTransaction].self) { response in
            self.scannedCode = nil
            if case .success(let response?) = response {
                if let transactions = response.result,
                   let transaction = transactions.first {
                    DispatchQueue.main.async {
                        self.scannedCode = nil
                        self.session.transactions.addAsFirst(transaction)
                        self.wasPaymentSuccessful = (transaction.result == .ACCEPTED)
                        self.showAlert = true
                        WayAppPay.session.shoppingCart.empty()
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
