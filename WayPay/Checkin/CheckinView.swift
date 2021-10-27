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
    
    @State private var showQRScanner = true
    @State private var scannedCode: String? = nil
    @State private var isAPICallOngoing = false
    @State private var scanError = false
    @State private var wasScanSuccessful: Bool = false
    @State private var selectedPrize: Int = -1
    @State private var checkin: WayPay.Checkin? = nil

        
    private func reset() {
        self.selectedPrize = -1
        session.checkin = nil
        isAPICallOngoing = false
        // TODO: checking shoppingcart
        self.showQRScanner = true
    }
    
    private func getRewardBalanceForCampaign(_ id: String, checkin: WayPay.Checkin) -> String {
        if let rewards = checkin.rewards {
            for reward in rewards where reward.campaignID == id {
                return reward.getFormattedBalance
            }
        }
        return "0"
    }
    
    private var areAPIcallsDisabled: Bool {
        return isAPICallOngoing
    }
    
    private var fullname: String {
        if let checkin = checkin {
            return (checkin.firstName ?? "") + (checkin.lastName != nil ? " " + checkin.lastName! : "")
        }
        return ""
    }

    
    var body: some View {
        if (showQRScanner && (self.checkin == nil)) {
            CodeCaptureView(showCodePicker: self.$showQRScanner, code: self.$scannedCode, codeTypes: WayPay.acceptedPaymentCodes, completion: self.handleScan)
                .navigationBarTitle(NSLocalizedString("Scan customer QR", comment: "navigationBarTitle"))
        } else if areAPIcallsDisabled {
            ProgressView(NSLocalizedString(WayPay.SingleMessage.progressView.text, comment: "Activity indicator"))
                .progressViewStyle(WayPay.WayPayProgressViewStyle())
                .alert(isPresented: $scanError) {
                    Alert(title: Text("QR not found"),
                          message: Text("Try again. If not found again, contact support@wayapp.com"),
                          dismissButton: .default(
                            Text(WayPay.SingleMessage.OK.text),
                            action: reset)
                    )}
        } else if let checkin = self.checkin {
            Form {
                Section(header:
                            Label(NSLocalizedString("Wallet", comment: "CheckinView: section title"), systemImage: "wallet.pass.fill")
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
                    if let rewards = checkin.rewards,
                       !rewards.isEmpty {
                        VStack(alignment: .leading) {
                            if let stampCampaign = session.activeStampCampaign(),
                               let amountToGetIt = stampCampaign.prize?.amountToGetIt {
                                Label {
                                    Text(stampCampaign.name + ": ") +
                                    Text(getRewardBalanceForCampaign(stampCampaign.id, checkin: checkin))
                                        .bold().foregroundColor(Color.green) +
                                        Text(" / " + "\(amountToGetIt)")
                                } icon: {
                                    Image(systemName: WayPay.Campaign.icon(format: .STAMP))
                                }
                                Divider()
                            }
                            if let pointCampaign = session.activePointCampaign(),
                               let prizes = pointCampaign.prizes,
                               let prize = prizes.first,
                               let amountToGetIt = prize.amountToGetIt {
                                Label {
                                    Text(pointCampaign.name + ": ") +
                                    Text(getRewardBalanceForCampaign(pointCampaign.id, checkin: checkin))
                                        .bold().foregroundColor(Color.green)
                                    Text(" / " + "\(amountToGetIt / 100)")
                                } icon: {
                                    Image(systemName: WayPay.Campaign.icon(format: .POINT))
                                }
                            }
                            if let issuerPointCampaign = session.activeIssuerPointCampaign() {
                                Label {
                                    Text(issuerPointCampaign.name + ": ") +
                                        Text(getRewardBalanceForCampaign(issuerPointCampaign.id, checkin: checkin))
                                        .bold().foregroundColor(Color.green)
                                } icon: {
                                    Image(systemName: WayPay.Campaign.icon(format: .POINT))
                                }
                                Divider()
                            }
                            if let issuerStampCampaign = session.activeIssuerStampCampaign() {
                                Label {
                                    Text(issuerStampCampaign.name + ": ") +
                                    Text(getRewardBalanceForCampaign(issuerStampCampaign.id, checkin: checkin))
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
                }
                Section(header:
                            Label(NSLocalizedString("Prizes", comment: "CheckinView: section title"), systemImage: "checkmark.seal.fill")
                            .font(.callout)) {
                    if let prizes = checkin.prizes,
                       !prizes.isEmpty {
                        ForEach(0..<prizes.count) {
                            Text((session.campaigns[prizes[$0].campaignID]?.name ?? "-") + ": " + prizes[$0].displayAs)
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
        guard let code = scannedCode else {
            WayAppUtils.Log.message("Missing scannedCode")
            return
        }
        isAPICallOngoing = true
        let transaction = WayPay.PaymentTransaction(amount: 0, token: code, type: .CHECKIN)
        WayPay.Account.checkin(transaction) { checkins, error in
            if let checkins = checkins,
               let checkin = checkins.first {
                DispatchQueue.main.async {
                    self.checkin = checkin
                    showQRScanner = true
                }
            }
            else {
                DispatchQueue.main.async {
                    self.scanError = true
                }
                WayAppUtils.Log.message("Get rewards error. More info: \(error != nil ? error!.localizedDescription : "not available")")
            }
            DispatchQueue.main.async {
                isAPICallOngoing = false
            }

        }
    }
}

struct CheckinView_Previews: PreviewProvider {
    static var previews: some View {
        CheckinView()
    }
}
