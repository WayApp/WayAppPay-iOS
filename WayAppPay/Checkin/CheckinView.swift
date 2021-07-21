//
//  CheckinView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 19/7/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct CheckinView: View {
    @EnvironmentObject private var session: WayPay.Session
    @SwiftUI.Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var showQRScanner = true
    @State private var scannedCode: String? = nil
    @State private var isAPICallOngoing = false
    @State private var scanError = false
    @State private var showTransactionResult = false
    @State private var wasTransactionSuccessful = false
    @State private var wasScanSuccessful: Bool = false
    @State private var checkin: WayPay.Checkin?
    @State private var selectedPrize: Int = -1

    private var fullname: String {
        if let checkin = checkin {
            return (checkin.firstName ?? "") + (checkin.lastName != nil ? " " + checkin.lastName! : "")
        }
        return ""
    }
    
    private var shoppingCartMenuOption: String {
        let count = session.shoppingCart.count
        return NSLocalizedString("Shopping cart", comment: "") + (count > 0 ? " (\(count))" : "")
    }
    
    private var transactionAmount: Int {
        if selectedPrize != -1,
           let prizes = checkin?.prizes {
            return prizes[selectedPrize].applyToAmount(session.amount)
        }
        return session.amount
    }

    private var actionButtons: some View {
        HStack {
            Button {
                handleQRScanPayment()
            } label: {
                Text("Charge \(WayPay.formatPrice(transactionAmount))")
                    .padding()
            }
            Spacer()
            Button(action: {
                self.displayScanner()
            }) {
                Text("Cancel")
                    .padding()
            }
            .animation(.easeInOut(duration: 0.3))
        }
        .buttonStyle(WayPay.ButtonModifier())
    }
    
    var body: some View {
        NavigationView {
            if (showQRScanner) {
                CodeCaptureView(showCodePicker: self.$showQRScanner, code: self.$scannedCode, codeTypes: WayPay.acceptedPaymentCodes, completion: self.handleScan)
                    .navigationBarTitle("Scan customer QR", displayMode: .inline)
            } else if isAPICallOngoing {
                ProgressView(NSLocalizedString("Please wait…", comment: "Activity indicator"))
                    .alert(isPresented: $scanError) {
                        Alert(title: Text("QR not found"),
                              message: Text("Try again. If not found again, contact support@wayapp.com"),
                              dismissButton: .default(
                                              Text("OK"),
                                              action: displayScanner)
                        )}
            } else if let checkin = checkin {
                Form {
                    Section(header:
                                Label(NSLocalizedString("Campaigns", comment: "CheckinView: button title"), systemImage: "person.fill.viewfinder")
                                .font(.callout)) {
                        if let rewards = checkin.rewards,
                           !rewards.isEmpty {
                            NavigationLink(destination: RewardsView(rewards: rewards)) {
                                Label(NSLocalizedString("Balance", comment: "CheckinView: Balances"), systemImage: "number.square")
                            }
                        } else {
                            Text("No campaigns")
                        }
                        if let prizes = checkin.prizes,
                           !prizes.isEmpty {
                            Picker(selection: $selectedPrize, label: Label("Has won", systemImage: "app.gift")
                                    .accessibility(label: Text("Has won"))) {
                                ForEach(0..<prizes.count) {
                                    Text(prizes[$0].displayAs)
                                        .font(Font.body)
                                }
                            }
                            .onChange(of: selectedPrize, perform: { merchant in
                                WayAppUtils.Log.message("selectedPrize success")

                            })
                        } else {
                            Text("Has not won any prize")
                        }
                    }
                    Section(header:
                                Label(NSLocalizedString("Payment", comment: "CheckinView: section title"), systemImage: "eurosign.square")
                                .font(.callout)) {
                        NavigationLink(destination: AmountView()) {
                            Label(NSLocalizedString("Enter amount", comment: "CheckinView: Enter amount"), systemImage: "square.grid.3x3")
                        }
                        NavigationLink(destination: OrderView()) {
                            Label(NSLocalizedString("Select products", comment: "CheckinView: Order from product catalogue option"), systemImage: "filemenu.and.selection")
                        }
                        NavigationLink(destination: ShoppingCartView()) {
                            Label(shoppingCartMenuOption, systemImage: "cart")
                        }
                    }
                    actionButtons
                }
                .navigationBarTitle(fullname, displayMode: .inline)
                .alert(isPresented: $showTransactionResult) {
                    Alert(
                        title: Text(wasTransactionSuccessful ? "✅" : "🚫")
                            .foregroundColor(wasTransactionSuccessful ? Color.green : Color.red)
                            .font(.title),
                        message: Text("Transaction" + " " + (wasTransactionSuccessful ? "was successful" : "failed")),
                        dismissButton: .default(
                                        Text("OK"),
                                        action: displayScanner)
                    )
                }
            }
    }
}
    private func displayScanner() {
        self.showTransactionResult = false
        self.wasTransactionSuccessful = false
        self.selectedPrize = -1
        self.checkin = nil
        WayPay.session.shoppingCart.empty()
        self.showQRScanner = true
    }
    
    private func transactionResult(accepted: Bool) {
        self.scannedCode = nil
        DispatchQueue.main.async {
            self.showTransactionResult = true
            self.wasTransactionSuccessful = accepted
        }
    }

    private func handleScan() {
        WayAppUtils.Log.message("Checking in")
        guard let code = scannedCode else {
            WayAppUtils.Log.message("Missing scannedCode")
            return
        }
        let transaction = WayPay.PaymentTransaction(amount: 0, token: code, type: .CHECKIN)
        isAPICallOngoing = true
        WayPay.Account.checkin(transaction) { checkins, error in
            //self.scannedCode = nil
            if let checkins = checkins,
               let checkin = checkins.first {
                DispatchQueue.main.async {
                    self.checkin = checkin
                    isAPICallOngoing = false
                }
                WayAppUtils.Log.message("Checkin success: \(checkin)")
            } else {
                DispatchQueue.main.async {
                    self.scanError = true
                }
                WayAppUtils.Log.message("Get rewards error. More info: \(error != nil ? error!.localizedDescription : "not available")")
            }
        }
    }
    
    func handleQRScanPayment() {
        guard let merchantUUID = session.merchantUUID,
              let accountUUID = session.accountUUID,
              let code = scannedCode else {
            WayAppUtils.Log.message("Missing session.merchantUUID or session.accountUUID")
            return
        }
        var prizes = [WayPay.Prize]()
        if selectedPrize != -1,
           let prize = checkin?.prizes?[selectedPrize] {
            prizes.append(prize)
        }
        let payment = WayPay.PaymentTransaction(amount: session.amount, purchaseDetail: session.shoppingCart.arrayOfCartItems, prizes: prizes, token: code)
        WayAppUtils.Log.message("++++++++++ WayAppPay.PaymentTransaction: \(payment)")
        isAPICallOngoing = true
        WayPay.API.walletPayment(merchantUUID, accountUUID, payment).fetch(type: [WayPay.PaymentTransaction].self) { response in
            DispatchQueue.main.async {
                isAPICallOngoing = false
            }
            switch response {
            case .success(let response?):
                WayAppUtils.Log.message("++++++++++ WayAppPay.PaymentTransaction: SUCCESS")
                if let transactions = response.result,
                   let transaction = transactions.first {
                    DispatchQueue.main.async {
                        self.transactionResult(accepted: transaction.result == .ACCEPTED)
                        self.session.transactions.addAsFirst(transaction)
                    }
                } else {
                    WayAppUtils.Log.message("INVALID_SERVER_DATA")
                    self.transactionResult(accepted: false)
                }
            case .failure(let error):
                WayAppUtils.Log.message("++++++++++ WayAppPay.PaymentTransaction: FAILED")
                WayAppUtils.Log.message(error.localizedDescription)
                self.transactionResult(accepted: false)
            default:
                self.transactionResult(accepted: false)
                WayAppUtils.Log.message("INVALID_SERVER_DATA")
            }
        }
    }

}

struct CheckinView_Previews: PreviewProvider {
    static var previews: some View {
        CheckinView()
    }
}
