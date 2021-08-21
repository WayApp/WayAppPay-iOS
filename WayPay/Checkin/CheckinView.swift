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
    @State private var selectedPrize: Int = -1

    private var fullname: String {
        if let checkin = session.checkin {
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
           let prizes = session.checkin?.prizes {
            return prizes[selectedPrize].applyToAmount(session.amount)
        }
        return session.amount
    }
    
    private func displayScanner() {
        self.showTransactionResult = false
        self.wasTransactionSuccessful = false
        self.selectedPrize = -1
        session.checkin = nil
        isAPICallOngoing = false
        // TODO: checking shoppingcart
        self.showQRScanner = true
    }
    
    private var actionButtons: some View {
        VStack {
            Button {
                handleQRScanPayment()
            } label: {
                Text("Charge \(WayPay.formatPrice(transactionAmount))")
                    .padding()
            }
            .buttonStyle(WayPay.WideButtonModifier())
            Button(action: {
                DispatchQueue.main.async {
                    self.displayScanner()
                }
            }) {
                Text("Cancel")
                    .padding()
            }
            .buttonStyle(WayPay.CancelButtonModifier())

        }
        .listRowInsets(EdgeInsets())
        .padding(.horizontal)
    }
    
    private func getRewardBalanceForCampaign(_ id: String) -> Int? {
        if let rewards = session.checkin?.rewards {
            for reward in rewards where reward.campaignID == id {
                return reward.balance
            }
        }
        return nil
    }
    
    var body: some View {
        if (showQRScanner && (session.checkin == nil)) {
            CodeCaptureView(showCodePicker: self.$showQRScanner, code: self.$scannedCode, codeTypes: WayPay.acceptedPaymentCodes, completion: self.handleScan)
                .navigationBarTitle(NSLocalizedString("Scan QR", comment: "navigationBarTitle"))
        } else if isAPICallOngoing {
            ProgressView(NSLocalizedString(WayPay.UserMessage.progressView.alert.title, comment: "Activity indicator"))
                .progressViewStyle(WayPay.WayPayProgressViewStyle())
                .alert(isPresented: $scanError) {
                    Alert(title: Text("QR not found"),
                          message: Text("Try again. If not found again, contact support@wayapp.com"),
                          dismissButton: .default(
                            Text("OK"),
                            action: displayScanner)
                    )}
        } else if let checkin = session.checkin {
            Form {
                Section(header:
                            Label(NSLocalizedString("Giftcard", comment: "CheckinView: section title"), systemImage: "gift.fill")
                            .font(.callout)) {
                    if let prepaidBalance = checkin.prepaidBalance {
                        Label {
                            Text("Balance" + ": ") +
                            Text(WayPay.formatPrice(prepaidBalance))
                                .bold().foregroundColor(Color.green)
                        } icon: {
                            Image(systemName: "banknote.fill")
                        }
                    }
                    if let merchant = session.merchant,
                       merchant.allowsGiftcard {
                        NavigationLink(destination: AmountView(scannedCode: scannedCode, displayOption: AmountView.DisplayOption.topup)) {
                            Label(NSLocalizedString("Top up", comment: "CheckinView: Enter amount"), systemImage: "plus.app.fill")
                        }
                    } else {
                        Link(NSLocalizedString("Contact sales@wayapp.com to enable", comment: "Request giftcard feature"), destination: URL(string: "mailto:sales@wayapp.com?subject=My own giftcard&body=Hello, I am interested in selling my own digital rechargable giftcard. Please contact me. Thanks.".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
                            .font(.caption)
                            .foregroundColor(Color.blue)
                    }
                }
                Section(header:
                            Label(NSLocalizedString("Campaigns", comment: "CheckinView: section title"), systemImage: "megaphone.fill")
                            .font(.callout)) {
                    if let rewards = checkin.rewards,
                       !rewards.isEmpty {
                        VStack(alignment: .leading) {
                            if let stampCampaign = session.activeStampCampaign(),
                               let amountToGetIt = stampCampaign.prize?.amountToGetIt {
                                Label {
                                    Text(stampCampaign.name + ": ") +
                                    Text(String(getRewardBalanceForCampaign(stampCampaign.id) ?? 0))
                                        .bold().foregroundColor(Color.green) +
                                    Text(" / " + "\(amountToGetIt)")
                                } icon: {
                                    Image(systemName: WayPay.Campaign.icon(format: .STAMP))
                                }
                                Divider()
                            }
                            if let pointCampaign = session.activePointCampaign() {
                                Label {
                                    Text(pointCampaign.name + ": ") +
                                    Text(String(getRewardBalanceForCampaign(pointCampaign.id) ?? 0))
                                        .bold().foregroundColor(Color.green)
                                } icon: {
                                    Image(systemName: WayPay.Campaign.icon(format: .POINT))
                                }
                                Divider()
                            }
                            if let issuerPointCampaign = session.activeIssuerPointCampaign() {
                                Label {
                                    Text(issuerPointCampaign.name + ": ") +
                                    Text(String(getRewardBalanceForCampaign(issuerPointCampaign.id) ?? 0))
                                        .bold().foregroundColor(Color.green)
                                } icon: {
                                    Image(systemName: WayPay.Campaign.icon(format: .POINT))
                                }
                                Divider()
                            }
                            if let issuerStampCampaign = session.activeIssuerStampCampaign() {
                                Label {
                                    Text(issuerStampCampaign.name + ": ") +
                                    Text(String(getRewardBalanceForCampaign(issuerStampCampaign.id) ?? 0))
                                        .bold().foregroundColor(Color.green)
                                } icon: {
                                    Image(systemName: WayPay.Campaign.icon(format: .STAMP))
                                }
                                Divider()
                            }
                        }
                    } else {
                        Text("No campaigns")
                    }
                    if let prizes = checkin.prizes,
                       !prizes.isEmpty {
                        ForEach(0..<prizes.count) {
                            Text(prizes[$0].displayAs)
                                .font(Font.body)
                        }
                    }
                }
                Section(header:
                            Label(NSLocalizedString("Activity", comment: "CheckinView: section title"), systemImage: "person.fill.viewfinder")
                            .font(.callout)) {
                    NavigationLink(destination: TransactionsView(accountUUID: checkin.accountUUID)) {
                        Label(NSLocalizedString("Recent purchases", comment: "CheckinView: Transactions"), systemImage: "calendar")
                    }
                }
                Section(header:
                            Label(NSLocalizedString("Order", comment: "CheckinView: section title"), systemImage: "cart.fill.badge.plus")
                            .font(.callout)) {
                    /*
                    NavigationLink(destination: AmountView()) {
                        Label(NSLocalizedString("Enter amount", comment: "CheckinView: Enter amount"), systemImage: "square.grid.3x3")
                    }
 */
                    NavigationLink(destination: OrderView()) {
                        Label(NSLocalizedString("Select products", comment: "CheckinView: Order from product catalogue option"), systemImage: "filemenu.and.selection")
                    }
                    NavigationLink(destination: ShoppingCartView()) {
                        Label(shoppingCartMenuOption, systemImage: "cart")
                    }
                }
                actionButtons
            }
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitle(fullname)
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
                    session.checkin = checkin
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
           let prize = session.checkin?.prizes?[selectedPrize] {
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
