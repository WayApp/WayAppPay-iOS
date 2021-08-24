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
    @State private var showStampHelp = false
    @State private var wasTransactionSuccessful = false
    @State private var isAPICallOngoing = false
    @State private var displayPromotionAlert = false
    let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)
    
    var purchaseAmountValueToDisplay: Int {
        WayAppUtils.Log.message("**********$$$$$$$$$$$ purchaseAmountValueToDisplay")
        var amount = purchaseAmountValue
        if let checkin = session.checkin {
            if session.selectedPrize != -1,
               let prizes = checkin.prizes {
                amount = prizes[session.selectedPrize].applyToAmount(amount)
            }
        }
        return amount
    }
    
    var purchaseAmountValue: Int {
        WayAppUtils.Log.message("**********$$$$$$$$$$$ purchaseAmountValue")
        var amount = WayAppUtils.composeIntPriceFromString(purchaseAmount)
        WayAppUtils.Log.message("purchaseAmount TextFielValue=\(amount)")
        if session.amount > 0 {
            amount = session.amount
        }
        WayAppUtils.Log.message("purchaseAmount TextFielValue + session.amount=\(amount)")
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
                } else {
                    displayPromotionAlert = true
                }
            }) {
                Label(NSLocalizedString("Reward purchase amount", comment: "CheckoutView: button title"), systemImage: WayPay.Campaign.icon(format: .POINT))
                    .padding()
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .background(!WayPay.Point.isPointCampaignActive() ? Color.blue.opacity(0.50) : Color.green)
            .cornerRadius(6)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .alert(isPresented: $displayPromotionAlert) {
                Alert(
                    title: Text("Premium feature")
                        .font(.title),
                    message: Text("Contact sales@wayapp.com to enable"),
                    dismissButton: .default(
                        Text("OK"),
                        action: {})
                )
            }
            Button(action: {
                if let stampCampaign = stampCampaign {
                    rewardLoyalty(campaign: stampCampaign)
                } else {
                    showStampHelp = true
                }
            }) {
                Label(NSLocalizedString("Reward visit", comment: "CheckoutView: button title"), systemImage: WayPay.Campaign.icon(format: .STAMP))
                    .padding()
            }
            .buttonStyle(WayPay.WideButtonModifier())
            .alert(isPresented: $showStampHelp) {
                Alert(
                    title: Text("Needs setup in Settings")
                        .font(.title),
                    message: Text("Needs activation on the Settings tab. Contact support@wayapp.com for help"),
                    dismissButton: .default(
                        Text("OK"),
                        action: {})
                )
            }
            Button(action: {
                if let stampCampaign = stampCampaign {
                    rewardLoyalty(campaign: stampCampaign)
                }
            }) {
                Label(NSLocalizedString("Community campaign", comment: "CheckoutView: button title"), systemImage: "network")
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
        session.shoppingCart.empty()
        session.checkin = nil
        session.selectedPrize = -1
        isAPICallOngoing = false
    }
    
    private var waypayButtonTitle: String {
        WayAppUtils.Log.message("Entering")
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
        WayAppUtils.Log.message("Entering")
        guard let token = session.checkin?.token else {
            WayAppUtils.Log.message("Missing checkin.token")
            return
        }
        isAPICallOngoing = true
        let transaction = WayPay.PaymentTransaction(amount: purchaseAmountValue, purchaseDetail: nil, prizes: selectedPrizes(), token: token, type: .REWARD)
        WayPay.Campaign.reward(transaction: transaction, campaign: campaign) { transactions, error in
            if let transactions = transactions,
               let transaction = transactions.first {
                DispatchQueue.main.async {
                    transactionResult(accepted: transaction.result == .ACCEPTED)
                }
                WayAppUtils.Log.message("rewardLoyalty success: \(transaction)")
            } else {
                DispatchQueue.main.async {
                    transactionResult(accepted: false)
                }
                WayAppUtils.Log.message("rewardLoyalty error. More info: \(error != nil ? error!.localizedDescription : "not available")")
            }
        }
    }
    
    private func selectedPrizes() -> [WayPay.Prize] {
        var prizes = [WayPay.Prize]()
        if session.selectedPrize != -1,
           let prize = session.checkin?.prizes?[session.selectedPrize] {
            prizes.append(prize)
        }
        return prizes
    }
    
    private func processPayment(amount: Int) {
        guard let token = session.checkin?.token,
              let accountUUID = session.accountUUID else {
            WayAppUtils.Log.message("Missing checkin.token")
            return
        }
        let merchantUUID = session.merchants[session.seletectedMerchant].merchantUUID
        let payment = WayPay.PaymentTransaction(amount: amount, purchaseDetail: nil, prizes: selectedPrizes(), token: token)
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
                        if session.imageDownloader != nil {
                            if let image = session.imageDownloader!.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 80, maxHeight: 80)
                                    .clipShape(Circle())
                            } else {
                                Image("WayPay-Hands")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 80, maxHeight: 80)
                            }
                        } else {
                            Image("WayPay-Hands")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 80, maxHeight: 80)
                        }
                        if (session.shoppingCart.isEmpty) {
                            Text("Enter purchase amount:")
                                .font(.caption)
                                .padding(.top)
                            HStack {
                                TextField(WayPay.formatAmount(purchaseAmountValue), text: $purchaseAmount)
                                    .font(.title)
                                    .frame(width: 120, height: 40)
                                    .keyboardType(.decimalPad)
                                    .modifier(WayPay.TextFieldModifier(padding: 10, lineWidth: 1))
                                Text(Locale.current.currencySymbol ?? "")
                            }
                            .padding()
                        }
                        if (purchaseAmountValue > 0 && session.checkin == nil) {
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
                        if (purchaseAmountValue > 0) {
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
                            if (checkin.isWayPayPaymentAvailable && purchaseAmountValue > 0) {
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
                        if (purchaseAmountValue > 0 || session.checkin != nil) {
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
            } // Scrollview
            .navigationTitle(WayPay.formatPrice(purchaseAmountValueToDisplay))
            // purchaseAmount.isEmpty ? NSLocalizedString("Amount", comment: "CheckoutView: navigationTitle") : WayPay.formatPrice(purchaseAmountValueToDisplay)
            .navigationBarItems(trailing:
                                    NavigationLink(destination: OrderView()) {
                                        Image(systemName: "cart.badge.plus")
                                            .imageScale(.large)
                                     }
                                    .overlay(Badge())
            )
            .gesture(DragGesture().onChanged { _ in hideKeyboard() })
            if isAPICallOngoing {
                ProgressView(WayPay.UserMessage.progressView.alert.title)
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
                Text(prize.displayAs)
                    .font(.body)
                    .multilineTextAlignment(.leading)
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
