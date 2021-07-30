//
//  PointOfSaleView.swift
//  WayPay
//
//  Created by Oscar Anzola on 29/7/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct PointOfSaleView: View {
    @EnvironmentObject var session: WayPay.Session
    @SwiftUI.Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var showScanner = false
    @State private var showAlert = false
    @State private var scannedCode: String? = nil
    @State private var cartDescription: String = ""
    @State private var wasPaymentSuccessful: Bool = false
    @State private var amount: Double = 0
    @State private var total: Double = 0
    
    @State private var showingActionSheet = false
    @State private var backgroundColor = Color.white

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
        total = 0
        cartDescription = ""
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func processPayment() {
        guard let merchantUUID = WayPay.session.merchantUUID,
            let accountUUID = WayPay.session.accountUUID,
            let code = scannedCode else {
            WayAppUtils.Log.message("missing session.merchantUUID or session.accountUUID")
            return
        }
        let payment = WayPay.PaymentTransaction(amount: Int((total + amount) * 100) / 100, token: code)
        WayPay.API.walletPayment(merchantUUID, accountUUID, payment).fetch(type: [WayPay.PaymentTransaction].self) { response in
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + WayPay.UI.paymentResultDisplayDuration) {
                        self.showAlert = false
                    }
                } else {
                    self.wasPaymentSuccessful = false
                    self.showAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + WayPay.UI.paymentResultDisplayDuration) {
                        self.showAlert = false
                    }
                    WayPay.API.reportError(response)
                }
            } else if case .failure(let error) = response {
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }

    }
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("CornSilk")
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .trailing) {
                    NavigationLink(destination: OrderView()) {
                        Label(NSLocalizedString("Product catalogue", comment: "Order from product catalogue"), systemImage: "list.bullet.rectangle")
                    }
                    .padding()
                    HStack {
                        Spacer()
                        Text(WayPay.currencyFormatter.string(for: Double((Double(amount) / 100)))!)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding()
                            .onTapGesture {
                                self.delete()
                            }
                        Button(action: {
                            delete()
                        }, label: {
                            Label("Delete", systemImage: "delete.left")
                                .accessibility(label: Text("Delete"))
                        })
                        Spacer()
                    }
                    if (false) {
                        TextField("shopping cart description", text: $cartDescription)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .background(Color.white)
                            .cornerRadius(WayPay.cornerRadius)
                            .padding()
                    }
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
                            OperationButtonView(icon: "plus.circle") {
                                total += amount
                                amount = 0
                            }
                        }
                    }
                    if (false) {
                        HStack {
                            Spacer()
                            NavigationLink(destination: OrderView()) {
                                Label(NSLocalizedString("Charge", comment: "Charge"), systemImage: "banknote")
                                    .padding()
                                    .foregroundColor(Color.white)
                            }
                            NavigationLink(destination: OrderView()) {
                                Label(NSLocalizedString("Campaign", comment: "Campaign"), systemImage: "megaphone")
                                    .padding()
                                    .foregroundColor(Color.white)
                            }
                            Spacer()
                        }
                        .buttonStyle(WayPay.ButtonModifier())
                        .padding()
                        NavigationLink(destination: PaymentOptionsView(topupAmount: (total + amount))) {
                            Label(NSLocalizedString("Other options", comment: "Other options"), systemImage: "ellipsis.circle")
                        }
                        .padding()
                    } else {
                        HStack {
                            Spacer()
                            Button {
                                if let merchantUUID = session.merchantUUID {
                                    WayPay.session.shoppingCart.addProduct(WayPay.Product(merchantUUID: merchantUUID,
                                                                                                name: NSLocalizedString("Amount", comment: "Product name for entered amount"), description: NSLocalizedString("Entered amount", comment: "Product description for entered amount"), price: Int((total + amount)*100 / 100)), isAmount: true)
                                    self.resetAmountAndDescription()
                                }
                            } label: {
                                Label("Add to cart \(WayPay.formatPrice(Int((total + amount)*100 / 100)))", systemImage: "cart.badge.plus")
                                    .accessibility(label: Text("Add to cart"))
                                    .padding()
                                    .foregroundColor(Color.white)
                            }
                            .buttonStyle(WayPay.ButtonModifier())
                            Spacer()
                        }
                        .buttonStyle(WayPay.ButtonModifier())
                        .padding()
                        NavigationLink(destination: PaymentOptionsView(topupAmount: total + amount)) {
                            Label(NSLocalizedString("Other options", comment: "Other options"), systemImage: "ellipsis.circle")
                        }
                        .padding()
                    }
                } // VStack
                .textFieldStyle(RoundedBorderTextFieldStyle())
                if showAlert {
                    Image(systemName: wasPaymentSuccessful ? WayPay.UI.paymentResultSuccessImage : WayPay.UI.paymentResultFailureImage)
                        .resizable()
                        .foregroundColor(wasPaymentSuccessful ? Color.green : Color.red)
                        .frame(width: WayPay.UI.paymentResultImageSize, height: WayPay.UI.paymentResultImageSize, alignment: .center)
                }
            }
            .navigationBarTitle("Amount", displayMode: .inline)
            .navigationBarItems(trailing:
                                    NavigationLink(destination: ShoppingCartView()) {
                                        Image(systemName: "cart")
                                    }
                                    .foregroundColor(Color("MintGreen"))
                                    .overlay(WayPay.Badge(count: self.session.shoppingCart.count).opacity(self.session.shoppingCart.count == 0 ? 0 : 1))
            )
        }
        .gesture(DragGesture().onChanged { _ in hideKeyboard() })
    }
    
}

struct PointOfSaleView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            AmountView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
        .environmentObject(WayPay.session)
    }
}
