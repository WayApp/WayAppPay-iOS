//
//  CampaignsView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 23/6/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject var session: WayPay.Session
    @State var navigationSelection: Int?
    @State var inputAmount: Bool = false
    @State private var purchaseAmount: String = ""
    @State private var showTransactionResult = false
    @State private var wasTransactionSuccessful = false
    @State private var isAPICallOngoing = false
    let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)

    var purchaseAmountValueToDisplay: Int {
        var amount = WayAppUtils.composeIntPriceFromString(purchaseAmount)
        if let checkin = session.checkin {
            if session.selectedPrize != -1,
               let prizes = checkin.prizes {
                amount = prizes[session.selectedPrize].applyToAmount(amount)
            }
            if let balance = checkin.prepaidBalance {
                return min(balance, amount)
            }
        }
        return amount
    }
    
    var purchaseAmountValue: Int {
        let amount = WayAppUtils.composeIntPriceFromString(purchaseAmount)
        if let checkin = session.checkin,
           let balance = checkin.prepaidBalance {
               return min(balance, amount)
        }
        return amount
    }
    
    var pointCampaign: WayPay.Campaign? {
        return session.points.first
    }
    
    var stampCampaign: WayPay.Campaign? {
        return session.stamps.first
    }
    
    private func transactionResult(accepted: Bool) {
        DispatchQueue.main.async {
            self.showTransactionResult = true
            self.wasTransactionSuccessful = accepted
        }
    }

    private var awardButtons: some View {
        VStack {
            Button(action: {
                if let pointCampaign = pointCampaign {
                    rewardLoyalty(campaign: pointCampaign)
                }
            }) {
                Label(NSLocalizedString("Reward purchase amount", comment: "CheckoutView: button title"), systemImage: WayPay.Campaign.icon(format: .POINT))
                    .padding()
            }
            .buttonStyle(WayPay.WideButtonModifier())
            .disabled(!WayPay.Point.isPointCampaignActive())
            if (!WayPay.Point.isPointCampaignActive()) {
                Link("↳ " + NSLocalizedString("Contact sales@wayapp.com to enable", comment: "Request points campaign feature"), destination: URL(string: "mailto:sales@wayapp.com?subject=Reward by € consumption&body=Hello, I am interested in using this feature. Please contact me. Thanks.".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
                    .font(.caption)
                    .foregroundColor(Color.blue)
            }
            Button(action: {
                if let stampCampaign = stampCampaign {
                    rewardLoyalty(campaign: stampCampaign)
                }
            }) {
                Label(NSLocalizedString("Reward visit", comment: "CheckoutView: button title"), systemImage: WayPay.Campaign.icon(format: .STAMP))
                    .padding()
            }
            .buttonStyle(WayPay.WideButtonModifier())
            .disabled(!WayPay.Stamp.isStampCampaignActive())
            Button(action: {
                if let stampCampaign = stampCampaign {
                    rewardLoyalty(campaign: stampCampaign)
                }
            }) {
                Label(NSLocalizedString("Reward community campaign", comment: "CheckoutView: button title"), systemImage: "building.2.fill")
                    .padding()
            }
            .buttonStyle(WayPay.WideButtonModifier())
            .disabled(!WayPay.Stamp.isIssuerStampCampaignActive() && !WayPay.Point.isIssuerPointCampaignActive())
        }
        .animation(.easeInOut(duration: 0.3))
        .listRowInsets(EdgeInsets())
        .padding(.horizontal)
    }

    private func reset() {
        purchaseAmount = ""
        session.checkin = nil
        session.selectedPrize = -1
        isAPICallOngoing = false
    }
    
    private var waypayButtonTitle: String {
        var title: String = "WayPay Payment"
        if let checkin = session.checkin {
            if let type = checkin.type,
               type == .POSTPAID {
                title = NSLocalizedString("Bank account payment", comment: "waypayButtonTitle")
            } else if let balance = checkin.prepaidBalance {
                if balance >= purchaseAmountValue {
                    title = NSLocalizedString("Deduct", comment: "waypayButtonTitle") + " "
                        + "\(WayPay.formatPrice(purchaseAmountValueToDisplay))" + " "
                        + NSLocalizedString("from giftcard", comment: "waypayButtonTitle")
                } else {
                    title = NSLocalizedString("Deduct", comment: "waypayButtonTitle") + " " +
                        "\(WayPay.formatPrice(balance)) of \(WayPay.formatPrice(purchaseAmountValueToDisplay))" + " "
                        + NSLocalizedString("from giftcard", comment: "waypayButtonTitle")
                }
            }
        }
        return title
    }
    
    private func rewardLoyalty(campaign: WayPay.Campaign) {
        guard let token = session.checkin?.token else {
            WayAppUtils.Log.message("Missing checkin.token")
            return
        }
        isAPICallOngoing = true
        let transaction = WayPay.PaymentTransaction(amount: purchaseAmountValue, token: token, type: .REWARD)
        WayPay.Campaign.reward(transaction: transaction, campaign: campaign) { transactions, error in
            if let transactions = transactions,
               let transaction = transactions.first {
                DispatchQueue.main.async {
                    transactionResult(accepted: transaction.result == .ACCEPTED)
                }
                WayAppUtils.Log.message("Checkin success: \(transaction)")
            } else {
                DispatchQueue.main.async {
                    transactionResult(accepted: false)
                }
                WayAppUtils.Log.message("Get rewards error. More info: \(error != nil ? error!.localizedDescription : "not available")")
            }
        }
    }
    
    private func processPayment(amount: Int) {
        guard let token = session.checkin?.token,
              let accountUUID = session.accountUUID else {
            WayAppUtils.Log.message("Missing checkin.token")
            return
        }
        let merchantUUID = session.merchants[session.seletectedMerchant].merchantUUID
        var prizes = [WayPay.Prize]()
        if session.selectedPrize != -1,
           let prize = session.checkin?.prizes?[session.selectedPrize] {
            prizes.append(prize)
        }
        let payment = WayPay.PaymentTransaction(amount: amount, purchaseDetail: nil, prizes: prizes, token: token)
        isAPICallOngoing = true
        WayPay.API.walletPayment(merchantUUID, accountUUID, payment).fetch(type: [WayPay.PaymentTransaction].self) { response in
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

    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    VStack(alignment: .center, spacing: 4) {
                        HStack {
                            TextField("\(purchaseAmount)", text: $purchaseAmount)
                                .font(.title)
                                .frame(width: 120, height: 40)
                                .keyboardType(.decimalPad)
                                .disabled(session.checkin != nil)
                                .modifier(WayPay.TextFieldModifier(padding: 10, lineWidth: 2))
                            Text("€")
                        }
                        .padding()
                        if (!purchaseAmount.isEmpty && session.checkin == nil) {
                            Button {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                self.navigationSelection = 0
                            } label: {
                                Label(NSLocalizedString("Scan customer QR", comment: "CheckoutView: button title"), systemImage: "qrcode.viewfinder")
                                    .padding()
                            }
                            .buttonStyle(WayPay.WideButtonModifier())
                            .padding(.horizontal)
                        }
                        if (!purchaseAmount.isEmpty) {
                            Divider()
                        }
                        if let checkin = session.checkin {
                            if let prizes = checkin.prizes,
                               !prizes.isEmpty {
                                VStack {
                                    Text("Redeem prize" + ":")
                                        .font(Font.headline)
                                        .foregroundColor(.secondary)
                                    VStack {
                                        ForEach(0 ..< prizes.count) { index in
                                            PrizeRow(prize: prizes[index], index: index)
                                                .padding(.horizontal)
                                            if index < prizes.count - 1 {
                                                Divider()
                                            }
                                        }
                                    }
                                    .background(Rectangle().fill(BackgroundStyle()))
                                    .clipShape(shape)
                                    .overlay(
                                        shape
                                            .inset(by: 0.5)
                                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                                    )
                                }
                                Divider()
                            }
                            awardButtons
                            Divider()
                            if (checkin.isWayPayPaymentAvailable) {
                                Button {
                                    processPayment(amount: purchaseAmountValue)
                                } label: {
                                    Text(waypayButtonTitle)
                                        .padding()
                                }
                                .buttonStyle(WayPay.WideButtonModifier())
                                .padding(.horizontal)
                                Divider()
                            }
                        }
                        if (!purchaseAmount.isEmpty || session.checkin != nil) {
                            Button {
                                reset()
                            } label: {
                                Text("Cancel")
                                    .padding()
                            }
                            .buttonStyle(WayPay.CancelButtonModifier())
                            .padding(.horizontal)
                        }
                    }
                    NavigationLink(destination: ScanView(campaign: nil, value: purchaseAmountValue), tag: 0, selection: $navigationSelection) {
                        EmptyView()
                    }
                } // VStack
                .padding()
                .frame(minWidth: 200, idealWidth: 400, maxWidth: 400)
                .frame(maxWidth: .infinity)
            } // Scrollview
            .navigationTitle(purchaseAmount.isEmpty ? "Amount" : WayPay.formatPrice(purchaseAmountValueToDisplay))
            .gesture(DragGesture().onChanged { _ in hideKeyboard() })
            if isAPICallOngoing {
                ProgressView(NSLocalizedString("Please wait…", comment: "Activity indicator"))
                    .progressViewStyle(WayPay.WayPayProgressViewStyle())
                    .alert(isPresented: $showTransactionResult) {
                        Alert(
                            title: Text(wasTransactionSuccessful ? "✅" : "🚫")
                                .foregroundColor(wasTransactionSuccessful ? Color.green : Color.red)
                                .font(.title),
                            message: Text("Transaction" + " " + (wasTransactionSuccessful ? "was successful" : "failed")),
                            dismissButton: .default(
                                Text("OK"),
                                action: reset)
                        )
                    }
            }
        }
    }
}

struct CircleToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            configuration.label.hidden()
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                .foregroundColor(configuration.isOn ? .accentColor : .secondary)
                .imageScale(.large)
                .font(Font.title)
        }
    }
}

struct PrizeRow: View {
    @EnvironmentObject var session: WayPay.Session
    var prize: WayPay.Prize
    var index: Int = -1

    @State private var checked = false
            
    var body: some View {
        Button(action: {
            if (session.selectedPrize == -1 || session.selectedPrize == index) {
                checked.toggle()
                session.selectedPrize = (session.selectedPrize == index) ? -1 : index
            }
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(prize.displayAs)
                        .font(.headline)
                }
                Spacer()
                Toggle("Complete", isOn: $checked)
            }
            .contentShape(Rectangle())
        }
        .tag(index)
        .buttonStyle(PlainButtonStyle())
        .toggleStyle(CircleToggleStyle())
    }
}
struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello")
    }
}
