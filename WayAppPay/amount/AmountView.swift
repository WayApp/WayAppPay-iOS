//
//  AmountView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct AmountView: View {
    @EnvironmentObject private var session: WayAppPay.Session

    @State private var showScanner = false
    @State private var showAlert = false
    @State private var scannedCode: String? = nil
    @State private var cartDescription: String = ""
    @State private var wasPaymentSuccessful: Bool = false
    @State private var amount: Double = 0
    
    func handleScan() {
        processPayment()
    }
    
    func numberEntered(number: Int) {
        if number < 10 {
            amount = (amount*10 + Double(number))
        } else {
            amount *= 100
        }
    }
    
    func delete() {
        amount = 0
    }
    
    private func resetAmountAndDescription() {
        amount = 0
        cartDescription = ""
    }
    
    func processPayment() {
        guard let merchantUUID = WayAppPay.session.merchantUUID,
            let accountUUID = WayAppPay.session.accountUUID,
            let code = scannedCode else {
            WayAppUtils.Log.message("missing session.merchantUUID or session.accountUUID")
            return
        }
        let payment = WayAppPay.PaymentTransaction(amount: Int(amount * 100) / 100, token: code)
        WayAppPay.API.walletPayment(merchantUUID, accountUUID, payment).fetch(type: [WayAppPay.PaymentTransaction].self) { response in
            self.scannedCode = nil
            if case .success(let response?) = response {
                if let transactions = response.result,
                    let transaction = transactions.first {
                    DispatchQueue.main.async {
                        self.resetAmountAndDescription()
                        self.session.transactions.addAsFirst(transaction)
                        self.wasPaymentSuccessful = (transaction.result == .ACCEPTED)
                        self.showAlert = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + WayAppPay.UI.paymentResultDisplayDuration) {
                        self.showAlert = false
                    }
                } else {
                    self.wasPaymentSuccessful = false
                    self.showAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + WayAppPay.UI.paymentResultDisplayDuration) {
                        self.showAlert = false
                    }
                    WayAppPay.API.reportError(response)
                }
            } else if case .failure(let error) = response {
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }

    }
    
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .center, spacing: 0.0) {
                    Spacer()
                    Text(WayAppPay.currencyFormatter.string(for: (amount / 100))!)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, WayAppPay.UI.verticalSeparation)
                        .onTapGesture {
                            self.delete()
                    }
                    TextField("shopping cart description", text: $cartDescription)
                        .modifier(WayAppPay.TextFieldModifier())
                        .modifier(WayAppPay.ClearButton(text: $cartDescription))
                        .padding()
                        .padding(.bottom, WayAppPay.UI.verticalSeparation * 3)
                    VStack {
                        HStack(spacing: 0) {
                            NumberButtonView(number: 1, completion: numberEntered)
                            NumberButtonView(number: 2, completion: numberEntered)
                            NumberButtonView(number: 3, completion: numberEntered)
                        }
                        HStack(spacing: 0) {
                            NumberButtonView(number: 4, completion: numberEntered)
                            NumberButtonView(number: 5, completion: numberEntered)
                            NumberButtonView(number: 6, completion: numberEntered)
                        }
                        HStack(spacing: 0) {
                            NumberButtonView(number: 7, completion: numberEntered)
                            NumberButtonView(number: 8, completion: numberEntered)
                            NumberButtonView(number: 9, completion: numberEntered)
                        }
                        HStack(spacing: 0) {
                            NumberButtonView(number: 100, completion: numberEntered)
                            NumberButtonView(number: 0, completion: numberEntered)
                            OperationButtonView(image: "delete.left", completion: delete)
                        }
                    }
                }
                if showAlert {
                    Image(systemName: wasPaymentSuccessful ? WayAppPay.UI.paymentResultSuccessImage : WayAppPay.UI.paymentResultFailureImage)
                        .resizable()
                        .foregroundColor(wasPaymentSuccessful ? Color.green : Color.red)
                        .frame(width: WayAppPay.UI.paymentResultImageSize, height: WayAppPay.UI.paymentResultImageSize, alignment: .center)
                }
            }
            .background(
                Image("WAP-Background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            )
            .navigationBarTitle("Amount", displayMode: .inline)
            .navigationBarItems(trailing:
                HStack {
                    Button(action: {
                        if let merchantUUID = session.merchantUUID {
                            WayAppPay.session.shoppingCart.addProduct(WayAppPay.Product(merchantUUID: merchantUUID, name: "Amount", description: self.cartDescription, price: String(self.amount / 100)), isAmount: true)
                            self.resetAmountAndDescription()
                        }
                    }, label: {
                        Image(systemName: "cart.fill.badge.plus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    })
                    .padding(.trailing, 16)
                    NavigationLink(destination: PaymentOptionsView(topupAmount: amount)) {
                        Image(systemName: "qrcode.viewfinder")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                    }
                    .foregroundColor(Color("WAP-Blue"))
                    .aspectRatio(contentMode: .fit)
                    .padding(.trailing, 16)
                    .disabled(amount == 0 && session.shoppingCart.isEmpty)
                }
                .foregroundColor(Color("WAP-Blue"))
                .frame(height: 30)
            )
        }
        .gesture(DragGesture().onChanged { _ in hideKeyboard() })
    }
    
}

struct AmountView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            AmountView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
        .environmentObject(WayAppPay.session)
    }
}
