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
                        self.session.transactions.addAsFirst(transaction)
                    }
                    self.wasPaymentSuccessful = (transaction.result == .ACCEPTED)
                    self.showAlert = true
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
                Color("WAP-Blue").edgesIgnoringSafeArea(.all)
                VStack(alignment: .center, spacing: 8.0) {
                    Spacer()
                    Text(WayAppPay.currencyFormatter.string(for: (amount / 100))!)
                        .font(.largeTitle)
                        .foregroundColor(Color.primary)
                        .fontWeight(.bold)
                        .onTapGesture {
                            self.delete()
                        }
                    TextField("description", text: $cartDescription)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 16.0)
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
            .navigationBarTitle("Amount")
            .navigationBarItems(trailing:
                HStack {
                    Button(action: {
                        WayAppPay.session.shoppingCart.addProduct(WayAppPay.Product(name: "Amount", description: self.cartDescription, price: Int(self.amount * 100) / 100), isAmount: true)
                    }, label: { Image(systemName: "cart.fill.badge.plus")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center) })
                        .aspectRatio(contentMode: .fit)
                        .padding(.trailing, 16)
                    Button(action: {
                        self.showScanner = true
                    }, label: { Image(systemName: "qrcode.viewfinder")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center) }
                    )
                    .sheet(isPresented: $showScanner) {
                        VStack {
                            CodeCaptureView(showCodePicker: self.$showScanner, code: self.$scannedCode, codeTypes: WayAppPay.acceptedPaymentCodes, completion: self.handleScan)
                            HStack {
                                Text("Charge: \(WayAppPay.currencyFormatter.string(for: (self.amount / 100))!)")
                                    .foregroundColor(Color.black)
                                    .fontWeight(.medium)
                                Spacer()
                                Button("Done") { self.showScanner = false }
                            }
                            .frame(height: 40.0)
                            .padding()
                            .background(Color.white)
                        }
                    }
                }
            )
        }
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
