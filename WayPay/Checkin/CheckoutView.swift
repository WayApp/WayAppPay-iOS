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
        var amount = purchaseAmountValue
        if let checkin = session.checkin {
            if session.selectedPrize != -1,
               let prizes = checkin.prizes {
                amount = prizes[session.selectedPrize].applyToAmount(amount)
            }
        }
        return amount
    }
    
    var waypayPaymentAmount: Int {
        if let checkin = session.checkin,
           let balance = checkin.prepaidBalance {
            return min(balance, purchaseAmountValue)
        }
        return 0
    }
    
    var purchaseAmountValue: Int {
        return session.amount > 0 ? session.amount : WayAppUtils.composeIntPriceFromString(purchaseAmount)
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
        HStack {
            Button(action: {
                if let pointCampaign = pointCampaign {
                    rewardLoyalty(campaign: pointCampaign)
                } else {
                    displayPromotionAlert = true
                }
            }) {
                Label(NSLocalizedString("Points", comment: "CheckoutView: button title"), systemImage: WayPay.Campaign.icon(format: .POINT))
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
                    title: Text(WayPay.AlertMessage.premiumFeature.text.title)
                        .font(.title),
                    message: Text(WayPay.AlertMessage.premiumFeature.text.message),
                    dismissButton: .default(
                        Text(WayPay.SingleMessage.OK.text),
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
                Label(NSLocalizedString("Stamp", comment: "CheckoutView: button title"), systemImage: WayPay.Campaign.icon(format: .STAMP))
                    .padding()
            }
            .buttonStyle(WayPay.WideButtonModifier())
            .alert(isPresented: $showStampHelp) {
                Alert(
                    title: Text(WayPay.AlertMessage.needsSetup.text.title)
                        .font(.title),
                    message: Text("Needs activation on the Settings tab. Contact support@wayapp.com for help"),
                    dismissButton: .default(
                        Text(WayPay.SingleMessage.OK.text),
                        action: {})
                )
            }
        }
        .animation(.easeInOut(duration: 1))
        .listRowInsets(EdgeInsets())
        .padding(.horizontal)
        .disabled(areAPIcallsDisabled)
    }
    
    private func reset() {
        purchaseAmount = ""
        session.shoppingCart.empty()
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
                    title = NSLocalizedString("Charge", comment: "waypayButtonTitle") + " "
                    + "\(WayPay.formatPrice(purchaseAmountValueToDisplay))"
                } else {
                    title = NSLocalizedString("Charge", comment: "waypayButtonTitle") + " " +
                    "\(WayPay.formatPrice(balance)) of \(WayPay.formatPrice(purchaseAmountValueToDisplay))"
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
        let transaction = WayPay.PaymentTransaction(amount: purchaseAmountValue, purchaseDetail: nil, prizes: selectedPrizes(), token: token, type: .REWARD)
        WayPay.Campaign.reward(transaction: transaction, campaign: campaign) { transactions, error in
            if let transactions = transactions,
               let transaction = transactions.first {
                DispatchQueue.main.async {
                    transactionResult(accepted: transaction.result == .ACCEPTED)
                    self.session.transactions.addAsFirst(transaction)
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
    
    private var areAPIcallsDisabled: Bool {
        return isAPICallOngoing
    }
    
    private var logo: Image {
        /*
        if session.imageDownloader != nil,
           let image = session.imageDownloader!.image {
            return Image(uiImage: image)
        } else {
            return Image("WayPay-Hands")
        }
        */
        return Image("WayPay-Hands")
    }
    
    private var allowsInputAmount: Bool {
        return (session.shoppingCart.isEmpty)
    }
    
    private var allowsScan: Bool {
        return (session.checkin == nil)
    }
    
    private var allowsWayPayPayment: Bool {
        if let checkin = session.checkin,
           checkin.isWayPayPaymentAvailable && purchaseAmountValue > 0 {
            return true
        }
        return false
    }
    
    private var showsPrizes: Bool {
        if let checkin = session.checkin,
           let prizes = checkin.prizes,
           !prizes.isEmpty {
            return true
        }
        return false
    }
    
    private var showsAwardButtons: Bool {
        if session.checkin != nil,
           purchaseAmountValue > 0 {
            return true
        }
        return false
    }
    
    private var showCustomerCheckin: Bool {
        if session.checkin == nil,
           purchaseAmountValue == 0 {
            return true
        }
        return false
    }
    
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    VStack(alignment: .center, spacing: 4) {
                        Spacer()
                        Group {
                            logo
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 40)
                            if (!WayPay.fullname.isEmpty) {
                                Text(WayPay.fullname)
                                    .font(.headline)
                            }
                        }
                        if (allowsInputAmount) {
                            HStack(alignment: .center) {
                                Text("Purchase amount:")
                                    .font(.body)
                                TextField(WayPay.formatAmount(purchaseAmountValue), text: $purchaseAmount)
                                    .font(.title)
                                    .frame(width: 120, height: 40)
                                    .keyboardType(.decimalPad)
                                    .modifier(WayPay.TextFieldModifier(padding: 10, lineWidth: 1))
                                    .multilineTextAlignment(.trailing)
                                Text(Locale.current.currencySymbol ?? "")
                                    .padding(.trailing)
                                Button(action: {
                                    reset()
                                }) {
                                    Image(systemName: "delete.left.fill")
                                        .resizable()
                                        .frame(width: 36.0, height: 30.0)
                                        .foregroundColor(Color.red)
                                }
                            }
                            .padding()
                        }
                        if (allowsScan) {
                            Button {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                self.navigationSelection = 0
                            } label: {
                                Text("Charge")
                                    .padding()
                            }
                            .buttonStyle(WayPay.WideButtonModifier())
                            .padding(.horizontal)
                            .disabled(areAPIcallsDisabled || purchaseAmountValue == 0)
                        }
                        if (showCustomerCheckin) {
                            Button {
                                self.navigationSelection = 1
                            } label: {
                                Label(NSLocalizedString("Balance", comment: "CheckoutView: button title"), systemImage: "qrcode.viewfinder")
                                    .padding()
                            }
                            .buttonStyle(WayPay.WideButtonModifier())
                            .padding(.horizontal)
                            .padding(.top)
                        }
                        if showsPrizes,
                           let prizes = session.checkin?.prizes {
                            HStack(alignment: .center) {
                                Text("Redeem prize" + ":")
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                VStack {
                                    ForEach(0 ..< prizes.count) { index in
                                        PrizeRow(prize: prizes[index], index: index)
                                            .padding(.horizontal)
                                            .padding(.vertical, 6)
                                        if index < prizes.count - 1 {
                                            Divider()
                                        }
                                    }
                                }
                                .background(Rectangle().fill(BackgroundStyle()))
                                .clipShape(shape)
                                .overlay(
                                    shape
                                        .inset(by: 0.75)
                                        .stroke(Color.primary.opacity(1.0), lineWidth: 0.75)
                                )
                            }
                            Divider()
                                .padding()
                        }
                        if (showsAwardButtons) {
                            awardButtons
                            Divider()
                                .padding()
                        }
                        if (allowsWayPayPayment) {
                            Button {
                                processPayment(amount: waypayPaymentAmount)
                            } label: {
                                Text(waypayButtonTitle)
                                    .padding()
                            }
                            .buttonStyle(WayPay.WideButtonModifier())
                            .padding(.horizontal)
                            .disabled(areAPIcallsDisabled)
                        }
                    }
                    NavigationLink(destination: ScanView(campaign: nil, value: purchaseAmountValue), tag: 0, selection: $navigationSelection) {
                        EmptyView()
                    }
                    NavigationLink(destination: CheckinView(), tag: 1, selection: $navigationSelection) {
                        EmptyView()
                    }
                } // VStack
                .padding()
            } // Scrollview
            .navigationTitle(WayPay.formatPrice(purchaseAmountValueToDisplay))
            // purchaseAmount.isEmpty ? NSLocalizedString("Amount", comment: "CheckoutView: navigationTitle") : WayPay.formatPrice(purchaseAmountValueToDisplay)
            .navigationBarItems(leading:
                                    NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape.fill")
                    .imageScale(.large)
            }
                                , trailing:
                                    NavigationLink(destination: TransactionsView()) {
                Image(systemName: "chart.bar.xaxis")
                    .imageScale(.large)
            })
            .gesture(DragGesture().onChanged { _ in hideKeyboard() })
            if areAPIcallsDisabled {
                ProgressView(WayPay.SingleMessage.progressView.text)
                    .progressViewStyle(WayPay.WayPayProgressViewStyle())
                    .alert(isPresented: $showTransactionResult) {
                        Alert(
                            title: Text(WayPay.AlertMessage.transaction(wasTransactionSuccessful).text.title)
                                .foregroundColor(wasTransactionSuccessful ? Color.green : Color.red)
                                .font(.title),
                            message: Text(WayPay.AlertMessage.transaction(wasTransactionSuccessful).text.message),
                            dismissButton: .default(
                                Text(WayPay.SingleMessage.OK.text),
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
