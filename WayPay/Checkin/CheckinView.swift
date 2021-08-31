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
    @State private var wasScanSuccessful: Bool = false
    @State private var selectedPrize: Int = -1

    private var fullname: String {
        if let checkin = session.checkin {
            return (checkin.firstName ?? "") + (checkin.lastName != nil ? " " + checkin.lastName! : "")
        }
        return ""
    }
    
    private func reset() {
        self.selectedPrize = -1
        session.checkin = nil
        isAPICallOngoing = false
        // TODO: checking shoppingcart
        self.showQRScanner = true
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
            ProgressView(NSLocalizedString(WayPay.SingleMessage.progressView.text, comment: "Activity indicator"))
                .progressViewStyle(WayPay.WayPayProgressViewStyle())
                .alert(isPresented: $scanError) {
                    Alert(title: Text("QR not found"),
                          message: Text("Try again. If not found again, contact support@wayapp.com"),
                          dismissButton: .default(
                            Text(WayPay.SingleMessage.OK.text),
                            action: reset)
                    )}
        } else if let checkin = session.checkin {
            Form {
                Section(header:
                            Label(NSLocalizedString("Giftcard", comment: "CheckinView: section title"), systemImage: "gift.fill")
                            .font(.callout)) {
                    if let prepaidBalance = checkin.prepaidBalance {
                        Label {
                            Text("Balance") + Text(": ")
                            Text(WayPay.formatPrice(prepaidBalance))
                                .bold().foregroundColor(Color.green)
                        } icon: {
                            Image(systemName: "banknote.fill")
                        }
                    }
                    if let merchant = session.merchant,
                       let scannedCode = scannedCode,
                       merchant.allowsGiftcard {
                        NavigationLink(destination: AmountView(scannedCode: scannedCode, displayOption: AmountView.DisplayOption.topup)) {
                            Label(NSLocalizedString("Top up", comment: "CheckinView: Enter amount"), systemImage: "plus.app.fill")
                        }
                    } else {
                        Link(NSLocalizedString("Contact sales@wayapp.com to enable", comment: "Request giftcard feature"), destination: URL(string: WayPay.SingleMessage.requestGiftcard.text)!)
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
                                    Text(WayPay.formatAmount(getRewardBalanceForCampaign(pointCampaign.id) ?? 0))
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
                            Label(NSLocalizedString("Activity", comment: "CheckinView: section title"), systemImage: "list.bullet.rectangle")
                            .font(.callout)) {
                    NavigationLink(destination: TransactionsView(accountUUID: checkin.accountUUID)) {
                        Label(NSLocalizedString("Recent purchases", comment: "CheckinView: Transactions"), systemImage: "calendar")
                    }
                }
                Button(action: {
                    DispatchQueue.main.async {
                        self.reset()
                    }
                }) {
                    Text("Cancel")
                        .padding()
                }
                .buttonStyle(WayPay.CancelButtonModifier())
            }
            .navigationBarTitle(fullname)
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
            if let checkins = checkins,
               let checkin = checkins.first {
                DispatchQueue.main.async {
                    session.checkin = checkin
                    showQRScanner = true
                    isAPICallOngoing = false
                }
            } else {
                DispatchQueue.main.async {
                    self.scanError = true
                }
                WayAppUtils.Log.message("Get rewards error. More info: \(error != nil ? error!.localizedDescription : "not available")")
            }
        }
    }
}

struct CheckinView_Previews: PreviewProvider {
    static var previews: some View {
        CheckinView()
    }
}
