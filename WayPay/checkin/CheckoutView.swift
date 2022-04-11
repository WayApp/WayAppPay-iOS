//
//  CampaignsView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 23/6/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject var session: WayPayApp.Session
    @State var navigationSelection: Int?
    @State var inputAmount: Bool = false
    @State private var purchaseAmount: String = ""
    @State private var showTransactionResult = false
    @State private var wasTransactionSuccessful = false
    @State private var isAPICallOngoing = false
    @State private var balanceNotSufficient = false
    @State private var animationAmount = 1.0
    @FocusState private var amountIsFocused: Bool


    let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)
    
    var purchaseAmountValueToDisplay: Int {
        var amount = purchaseAmountValue
        var availableBalance = Int.max
        if let checkin = session.checkin {
            if session.selectedPrize != -1,
               let prizes = checkin.prizes {
                amount = prizes[session.selectedPrize].applyToAmount(amount)
            }
            if let balance = checkin.prepaidBalance {
                availableBalance = balance
            }
        }
        return min(amount, availableBalance)
    }
    
    var waypayPaymentAmount: Int {
        guard let checkin = session.checkin,
              let type = checkin.type else {
            return 0
        }
        switch type {
        case .POSTPAID: return purchaseAmountValue
        case .PREPAID, .GIFTCARD:
            if let balance = checkin.prepaidBalance {
                return min(balance, purchaseAmountValue)
            }
        default:
            return 0
        }
        return 0
    }
    
    var purchaseAmountValue: Int {
        return WayAppUtils.composeIntPriceFromString(purchaseAmount)
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
                if let pointCampaign = WayPay.Campaign.activeCampaignWithFormat(.POINT, campaigns: session.checkin?.communityCampaigns) {
                    rewardLoyalty(campaign: pointCampaign)
                }
            }) {
                Label(NSLocalizedString("Points", comment: "CheckoutView: button title"), systemImage: WayPay.Campaign.icon(format: .POINT))
                    .padding()
            }
            .disabled(areAPIcallsDisabled || WayPay.Campaign.activeCampaignWithFormat(.POINT, campaigns: session.checkin?.communityCampaigns) == nil)
            Button(action: {
                if let stampCampaign = WayPay.Campaign.activeCampaignWithFormat(.STAMP, campaigns: session.checkin?.communityCampaigns) {
                    rewardLoyalty(campaign: stampCampaign)
                }
            }) {
                Label(NSLocalizedString("Stamp", comment: "CheckoutView: button title"), systemImage: WayPay.Campaign.icon(format: .STAMP))
                    .padding()
            }
            .disabled(areAPIcallsDisabled || WayPay.Campaign.activeCampaignWithFormat(.STAMP, campaigns: session.checkin?.communityCampaigns) == nil)
        }
        .buttonStyle(UI.WideButtonModifier())
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
            } else if checkin.prepaidBalance != nil {
                title = NSLocalizedString("Charge", comment: "waypayButtonTitle") + " "
                + "\(UI.formatPrice(purchaseAmountValueToDisplay))"
            }
        }
        return title
    }
    
    private func rewardLoyalty(campaign: WayPay.Campaign) {
        guard let token = session.checkin?.token else {
            Logger.message("Missing checkin.token")
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
                Logger.message("rewardLoyalty success: \(transaction)")
            } else {
                DispatchQueue.main.async {
                    transactionResult(accepted: false)
                }
                Logger.message("rewardLoyalty error. More info: \(error != nil ? error!.localizedDescription : "not available")")
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
              let accountUUID = session.accountUUID,
              let merchant = session.merchant else {
                  Logger.message("Missing checkin.token")
                  return
              }
        let merchantUUID = merchant.merchantUUID
        let payment = WayPay.PaymentTransaction(amount: amount, purchaseDetail: nil, prizes: selectedPrizes(), token: token)
        Logger.message("Transaction: \(payment)")
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
                    Logger.message("INVALID_SERVER_DATA")
                    self.transactionResult(accepted: false)
                }
            case .failure(let error):
                Logger.message("++++++++++ WayAppPay.PaymentTransaction: FAILED")
                Logger.message(error.localizedDescription)
                self.transactionResult(accepted: false)
            default:
                self.transactionResult(accepted: false)
                Logger.message("INVALID_SERVER_DATA")
            }
        }
    }
    
    private var areAPIcallsDisabled: Bool {
        return isAPICallOngoing
    }
    
    private var logo: Image {
        return Image("WayPay-Hands")
    }
    
    private var allowsInputAmount: Bool {
        return (session.checkin == nil)
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
                        logo
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 40)
                        if (!UI.fullname.isEmpty) {
                            Text(UI.fullname)
                                .font(.headline)
                        }
                        HStack(alignment: .center) {
                            Text("Purchase amount:")
                                .font(.body)
                            TextField(UI.formatAmount(purchaseAmountValue), text: $purchaseAmount)
                                .font(.title)
                                .frame(width: 120, height: 40)
                                .keyboardType(.decimalPad)
                                .modifier(UI.TextFieldModifier(padding: 10, lineWidth: 1))
                                .multilineTextAlignment(.trailing)
                                .disabled(!allowsInputAmount)
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
                        if (allowsScan) {
                            Button {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                self.navigationSelection = 0
                            } label: {
                                Text("Charge or reward")
                                    .padding()
                            }
                            .buttonStyle(UI.WideButtonModifier())
                            .padding(.horizontal)
                            .disabled(areAPIcallsDisabled || purchaseAmountValue == 0)
                        }
                        if (showCustomerCheckin) {
                            Button {
                                self.navigationSelection = 1
                            } label: {
                                Label(NSLocalizedString("Only scan", comment: "CheckoutView: button title"), systemImage: "qrcode.viewfinder")
                                    .padding()
                            }
                            .buttonStyle(UI.WideButtonModifier())
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
                                    ForEach(0 ..< prizes.count, id:\.self) { index in
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
                            .buttonStyle(UI.WideButtonModifier())
                            .padding(.horizontal)
                            .disabled(areAPIcallsDisabled)
                            .alert(isPresented: $balanceNotSufficient) {
                                Alert(
                                    title: Text(WayPay.AlertMessage.balanceNotSufficient.text.title)
                                        .font(.title),
                                    message: Text(WayPay.AlertMessage.balanceNotSufficient.text.message),
                                    dismissButton: .default(
                                        Text(WayPay.SingleMessage.OK.text))
                                )
                            }
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
            .navigationTitle(UI.formatPrice(purchaseAmountValueToDisplay))
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
                    .progressViewStyle(UI.WayPayProgressViewStyle())
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
        .onAppear(perform: {
            if let checkin = session.checkin,
               let balance = checkin.prepaidBalance,
               balance < purchaseAmountValue {
                DispatchQueue.main.async {
                    self.balanceNotSufficient = true
                }
            }
        })
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
    @EnvironmentObject var session: WayPayApp.Session
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

