//
//  ShoppingCartView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct ShoppingCartView: View {
    @EnvironmentObject private var session: WayAppPay.Session
 
    @State private var showScanner = false
    @State private var showAlert = false
    @State private var scannedCode: String? = nil
    @State private var wasPaymentSuccessful: Bool = false

    func handleScan() {
        processPayment()
    }
    
    func processPayment() {
        guard let merchantUUID = session.merchantUUID,
            let accountUUID = session.accountUUID,
            let code = scannedCode else {
            WayAppUtils.Log.message("missing session.merchantUUID or session.accountUUID")
            return
        }
        let payment = WayAppPay.PaymentTransaction(amount: Int(session.amount * 100), token: code)
        WayAppPay.API.walletPayment(merchantUUID, accountUUID, payment).fetch(type: [WayAppPay.PaymentTransaction].self) { response in
            self.scannedCode = nil
            if case .success(let response?) = response {
                if let transactions = response.result,
                    let transaction = transactions.first {
                    DispatchQueue.main.async {
                        self.session.transactions.addAsFirst(transaction)
                    }
                    self.wasPaymentSuccessful = (transaction.result == .ACCEPTED)
                    self.session.transactions.addAsFirst(transaction)
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
                List {
                    ForEach(session.shoppingCart.items) { item in
                        ShoppingCartRowView(item: item)
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(GroupedListStyle())
                .navigationBarTitle(WayAppPay.currencyFormatter.string(for: session.amount)!)
                .navigationBarItems(trailing:
                    Button(action: {
                        self.showScanner = true
                    }, label: { Image(systemName: "qrcode.viewfinder")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center) })
                        .aspectRatio(contentMode: .fit)
                        .padding(.trailing, 16)
                )
                .sheet(isPresented: $showScanner) {
                    VStack {
                        CodeCaptureView(showCodePicker: self.$showScanner, code: self.$scannedCode, codeTypes: WayAppPay.acceptedPaymentCodes, completion: self.handleScan)
                        HStack {
                            Text("Charge: \(WayAppPay.currencyFormatter.string(for: (self.session.amount))!)")
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
                if showAlert {
                    Image(systemName: wasPaymentSuccessful ? WayAppPay.UI.paymentResultSuccessImage : WayAppPay.UI.paymentResultFailureImage)
                        .resizable()
                        .foregroundColor(wasPaymentSuccessful ? Color.green : Color.red)
                        .frame(width: WayAppPay.UI.paymentResultImageSize, height: WayAppPay.UI.paymentResultImageSize, alignment: .center)
                }
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        session.shoppingCart.items.remove(at: offsets)
    }


}

struct ShoppingCartView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingCartView()
    }
}
