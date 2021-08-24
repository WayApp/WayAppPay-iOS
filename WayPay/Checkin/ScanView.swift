//
//  CheckinView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 19/7/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct ScanView: View {
    @EnvironmentObject private var session: WayPay.Session
    @SwiftUI.Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var showQRScanner = true
    @State private var scannedCode: String? = nil
    @State private var isAPICallOngoing = false
    @State private var scanError = false
    @State private var showTransactionResult = false
    @State private var wasTransactionSuccessful = false
    @State private var wasScanSuccessful: Bool = false
    
    var campaign: WayPay.Campaign?
    var value: Int?
    
        
    var body: some View {
        if (showQRScanner) {
            CodeCaptureView(showCodePicker: self.$showQRScanner, code: self.$scannedCode, codeTypes: WayPay.acceptedPaymentCodes, completion: self.handleScan)
                .navigationBarTitle(NSLocalizedString("Scan QR", comment: "navigationBarTitle"))
        } else if isAPICallOngoing {
            ProgressView(NSLocalizedString(WayPay.UserMessage.progressView.alert.title, comment: "Activity indicator"))
                .progressViewStyle(WayPay.WayPayProgressViewStyle())
                .alert(isPresented: $showTransactionResult) {
                    Alert(
                        title: Text(wasTransactionSuccessful ? "✅" : "🚫")
                            .foregroundColor(wasTransactionSuccessful ? Color.green : Color.red)
                            .font(.title),
                        message: Text("Scan" + " " + (wasTransactionSuccessful ? "was successful" : "failed")),
                        dismissButton: .default(
                            Text("OK"),
                            action: goBack)
                    )
                }
        }
    }
    
    private func goBack() {
        isAPICallOngoing = false
        self.presentationMode.wrappedValue.dismiss()
    }
    
    private func scanResult(accepted: Bool) {
        self.scannedCode = nil
        DispatchQueue.main.async {
            self.showTransactionResult = true
            self.wasTransactionSuccessful = accepted
        }
    }
    
    private func handleScan() {
        WayAppUtils.Log.message("QR was svanned")
        guard let code = scannedCode,
              let value = value else {
            WayAppUtils.Log.message("Missing scannedCode")
            return
        }
        isAPICallOngoing = true
        if let campaign = campaign {
            let transaction = WayPay.PaymentTransaction(amount: value, token: code, type: .REWARD)
            WayPay.Campaign.reward(transaction: transaction, campaign: campaign) { transactions, error in
                //self.scannedCode = nil
                if let transactions = transactions,
                   let transaction = transactions.first {
                    DispatchQueue.main.async {
                        scanResult(accepted: transaction.result == .ACCEPTED)
                    }
                    WayAppUtils.Log.message("Checkin success: \(transaction)")
                } else {
                    DispatchQueue.main.async {
                        scanResult(accepted: false)
                    }
                    WayAppUtils.Log.message("Get rewards error. More info: \(error != nil ? error!.localizedDescription : "not available")")
                }
            }
        } else {
            let transaction = WayPay.PaymentTransaction(amount: 0, token: code, type: .CHECKIN)
            WayPay.Account.checkin(transaction) { checkins, error in
                //self.scannedCode = nil
                if let checkins = checkins,
                   let checkin = checkins.first {
                    DispatchQueue.main.async {
                        session.checkin = checkin
                        self.goBack()                    }
                    WayAppUtils.Log.message("Scan success: \(checkin)")
                } else {
                    DispatchQueue.main.async {
                        self.scanResult(accepted: false)
                    }
                    WayAppUtils.Log.message("Checkin error. More info: \(error != nil ? error!.localizedDescription : "not available")")
                }
            }

        }
    }
    
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello")
    }
}
