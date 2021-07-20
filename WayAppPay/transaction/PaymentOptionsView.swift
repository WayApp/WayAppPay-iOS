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
    @SwiftUI.Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var showQRScannerForPayment = false
    @State private var showQRScannerForCheckin = false
    @State private var showNFCScannerForPayment = false
    @State private var showQRScannerForReward = false
    @State private var showQRScannerForGetRewards = false
    @State private var showQRScannerForUpdate = false
    @State private var showNFCScannerForUpdate = false
    @State private var showAlert = false
    @State private var scannedCode: String? = nil
    @State private var wasPaymentSuccessful: Bool = false
    @State private var showCheckinScanner = false
    @State private var isAPICallOngoing = false
    @State private var selectedCampaignID: String = String()
    
    var topupAmount: Int = 0
    let rowHeight: CGFloat = 60.0
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .leading) {
                    Text("Payment")
                        .font(.title)
                    List {
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
                        if (topupAmount > 0) {
                            Button(action: {
                                WayAppUtils.Log.message("Topup button pressed")
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
                        } // if
                        Button(action: {
                            WayAppUtils.Log.message("Get rewards button pressed")
                            self.showQRScannerForGetRewards = true
                        }, label: {
                            HStack {
                                Image(systemName: "plus.square")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30, alignment: .leading)
                                Text("Check rewards")
                            }
                        })
                        .sheet(isPresented: $showQRScannerForGetRewards) {
                            VStack {
                                CodeCaptureView(showCodePicker: self.$showQRScannerForGetRewards, code: self.$scannedCode, codeTypes: WayAppPay.acceptedPaymentCodes, completion: self.handleGetRewards)
                                HStack {
                                    Text("Rewards")
                                        .foregroundColor(Color.black)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Button("Done") { self.showQRScannerForGetRewards = false }
                                }
                                .frame(height: 40.0)
                                .padding()
                                .background(Color.white)
                            }
                        } // sheet
                        Button(action: {
                            WayAppUtils.Log.message("Checkin button pressed")
                            self.showQRScannerForCheckin = true
                        }, label: {
                            HStack {
                                Image(systemName: "plus.square")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30, alignment: .leading)
                                Text("Checkin")
                            }
                        })
                        .sheet(isPresented: $showQRScannerForCheckin) {
                            VStack {
                                CodeCaptureView(showCodePicker: self.$showQRScannerForCheckin, code: self.$scannedCode, codeTypes: WayAppPay.acceptedPaymentCodes, completion: self.handleCheckin)
                                HStack {
                                    Text("Checkin")
                                        .foregroundColor(Color.black)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Button("Done") { self.showQRScannerForCheckin = false }
                                }
                                .frame(height: 40.0)
                                .padding()
                                .background(Color.white)
                            }
                        } // sheet
                    }
                    if (topupAmount > 0) {
                        Text("Campaigns")
                            .font(.title)
                        List {
                            ForEach(session.campaigns) { campaign in
                                Button(action: {
                                    WayAppUtils.Log.message("Reward campaign button pressed, name: \(campaign.name)")
                                    self.showQRScannerForReward = true
                                    self.selectedCampaignID = campaign.id
                                }, label: {
                                    Text(campaign.name)
                                })
                            } // ForEach
                        } // List
                        .sheet(isPresented: $showQRScannerForReward) {
                            VStack {
                                CodeCaptureView(showCodePicker: self.$showQRScannerForReward, code: self.$scannedCode, codeTypes: WayAppPay.acceptedPaymentCodes, completion: self.handleReward)
                                HStack {
                                    Label(session.campaigns[selectedCampaignID]?.name ?? "Reward", systemImage: "list.bullet.rectangle")
                                    Spacer()
                                    Button("Done") { self.showQRScannerForReward = false }
                                }
                                .frame(height: 40.0)
                                .padding()
                                .background(Color.white)
                            }
                        } // sheet
                    } // if
                } // VStack
                .padding()
                if showAlert {
                    Image(systemName: wasPaymentSuccessful ? WayAppPay.UI.paymentResultSuccessImage : WayAppPay.UI.paymentResultFailureImage)
                        .resizable()
                        .foregroundColor(wasPaymentSuccessful ? Color.green : Color.red)
                        .frame(width: WayAppPay.UI.paymentResultImageSize, height: WayAppPay.UI.paymentResultImageSize, alignment: .center)
                }
                if isAPICallOngoing {
                    ProgressView(NSLocalizedString("Please wait…", comment: "Activity indicator"))
                }
            } // ZStack
            .foregroundColor(.primary)
            .navigationBarTitle(NSLocalizedString("Operation", comment: "Scanning transaction type"), displayMode: .inline)
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
    func handleCheckin() {
        WayAppUtils.Log.message("Checking in")
        guard let code = scannedCode else {
            WayAppUtils.Log.message("Missing scannedCode")
            return
        }
        let transaction = WayAppPay.PaymentTransaction(amount: 0, token: code, type: .CHECKIN)
        isAPICallOngoing = true
        WayAppPay.Account.checkin(transaction) { checkins, error in
            self.scannedCode = nil
            DispatchQueue.main.async {
                isAPICallOngoing = false
            }
            if let checkins = checkins,
               let checkin = checkins.first {
                WayAppUtils.Log.message("Checkin success: \(checkin)")
                DispatchQueue.main.async {
                    self.apiCallResult(accepted: true)
                }
            } else {
                self.apiCallResult(accepted: false)
                DispatchQueue.main.async {
                    // campaignCreateError = true
                }
                WayAppUtils.Log.message("Get rewards error. More info: \(error != nil ? error!.localizedDescription : "not available")")
            }
        }

    }
    
    func handleGetRewards() {
        WayAppUtils.Log.message("Getting rewards")
        guard let code = scannedCode else {
            WayAppUtils.Log.message("Missing scannedCode")
            return
        }
        let transaction = WayAppPay.PaymentTransaction(amount: 0, token: code, type: .REWARD)
        isAPICallOngoing = true
        WayAppPay.Account.getRewards(transaction) { rewards, error in
            self.scannedCode = nil
            DispatchQueue.main.async {
                isAPICallOngoing = false
            }
            if let rewards = rewards {
                WayAppUtils.Log.message("Get rewards success. Number of rewards: \(rewards.count)")
                let prizes = WayAppPay.Campaign.prizesForRewards(rewards)
                WayAppUtils.Log.message("Number of prizes: \(prizes.count)")
                for prize in prizes {
                    WayAppUtils.Log.message("Prize: \(prize)")
                }
                DispatchQueue.main.async {
                    self.apiCallResult(accepted: transaction.result == .ACCEPTED)
                }
            } else {
                self.apiCallResult(accepted: false)
                DispatchQueue.main.async {
                    // campaignCreateError = true
                }
                WayAppUtils.Log.message("Get rewards error. More info: \(error != nil ? error!.localizedDescription : "not available")")
            }
        }
    }

    func handleReward() {
        WayAppUtils.Log.message("Rewarding campaign: \(selectedCampaignID)")
        guard let code = scannedCode,
              let campaign = session.campaigns[self.selectedCampaignID] else {
            WayAppUtils.Log.message("Missing scannedCode or campaign")
            return
        }
        let reward = WayAppPay.PaymentTransaction(amount: topupAmount, token: code, type: .REWARD)
        isAPICallOngoing = true
        WayAppPay.Campaign.reward(transaction: reward, campaign: campaign) { transactions, error in
            self.scannedCode = nil
            DispatchQueue.main.async {
                isAPICallOngoing = false
            }
            if let transactions = transactions,
               let transaction = transactions.first {
                WayAppUtils.Log.message("Campaign reward success.Transaction: \(transaction)")
                DispatchQueue.main.async {
                    self.apiCallResult(accepted: transaction.result == .ACCEPTED)
                    self.session.transactions.addAsFirst(transaction)
                }
            } else {
                self.apiCallResult(accepted: false)
                DispatchQueue.main.async {
                    // campaignCreateError = true
                }
                WayAppUtils.Log.message("Campaign reward error. More info: \(error != nil ? error!.localizedDescription : "not available")")
            }
        }
    }
    
    func handleTopup() {
        WayAppUtils.Log.message("Topping up: \(topupAmount)")
        guard let code = scannedCode else {
            WayAppUtils.Log.message("Missing session.merchantUUID or session.accountUUID")
            return
        }
        let topup = WayAppPay.PaymentTransaction(amount: Int(topupAmount), token: code, type: .TOPUP)
        isAPICallOngoing = true
        WayAppPay.API.topup(topup).fetch(type: [WayAppPay.PaymentTransaction].self) { response in
            self.scannedCode = nil
            if case .success(let response?) = response,
               let transactions = response.result,
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
            } else if case .failure(let error) = response {
                WayAppUtils.Log.message(error.localizedDescription)
                WayAppUtils.Log.message("++++++++++ WayAppPay.PaymentTransaction: FAILED")
                self.wasPaymentSuccessful = false
                self.showAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + WayAppPay.UI.paymentResultDisplayDuration) {
                    self.showAlert = false
                }
            }
        }
    }
    
    func handleNFCScan() {
        WayAppUtils.Log.message("Scanned NFC Tag: \(scannedCode ?? "no scanned code")")
        handleQRScanPayment()
    }
    
}

// QR Payment
extension PaymentOptionsView {
    private func apiCallResult(accepted: Bool) {
        DispatchQueue.main.async {
            self.scannedCode = nil
            self.wasPaymentSuccessful = accepted
            self.showAlert = true
            WayAppPay.session.shoppingCart.empty()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + WayAppPay.UI.paymentResultDisplayDuration) {
            self.showAlert = false
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
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
        isAPICallOngoing = true
        WayAppPay.API.walletPayment(merchantUUID, accountUUID, payment).fetch(type: [WayAppPay.PaymentTransaction].self) { response in
            self.scannedCode = nil
            DispatchQueue.main.async {
                isAPICallOngoing = false
            }
            switch response {
            case .success(let response?):
                WayAppUtils.Log.message("++++++++++ WayAppPay.PaymentTransaction: SUCCESS")
                if let transactions = response.result,
                   let transaction = transactions.first {
                    DispatchQueue.main.async {
                        self.apiCallResult(accepted: transaction.result == .ACCEPTED)
                        self.session.transactions.addAsFirst(transaction)
                    }
                } else {
                    WayAppUtils.Log.message("INVALID_SERVER_DATA")
                    self.apiCallResult(accepted: false)
                }
            case .failure(let error):
                WayAppUtils.Log.message("++++++++++ WayAppPay.PaymentTransaction: FAILED")
                WayAppUtils.Log.message(error.localizedDescription)
                self.apiCallResult(accepted: false)
            default:
                self.apiCallResult(accepted: false)
                WayAppUtils.Log.message("INVALID_SERVER_DATA")
            }
        }
    }
}
