//
//  TransactionRowView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/6/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct TransactionRowView: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var session: WayPay.Session
    var transaction: WayPay.PaymentTransaction
    
    @State private var send = false
    
    @State var email: String = UserDefaults.standard.string(forKey: WayPay.DefaultKey.EMAIL.rawValue) ?? ""

    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    var shouldSendEmailButtonBeDisabled: Bool {
        return !WayAppUtils.validateEmail(email)
    }

    @ObservedObject private var keyboardObserver = WayPay.KeyboardObserver()

    var body: some View {
        HStack {
            transaction.result?.image
            VStack(alignment: .leading, spacing: 8) {
                Text(transaction.lastUpdateDate != nil ? TransactionRowView.dateFormatter.string(from: transaction.lastUpdateDate!) : "no date")
                Text(transaction.type?.title ?? WayPay.PaymentTransaction.TransactionType.defaultTitle)
                    .font(.subheadline)
                Text(transaction.getPurchaseDetail())
                    .font(.footnote)
            }.contextMenu {
                if ((transaction.type == WayPay.PaymentTransaction.TransactionType.SALE && !transaction.isPOSTPAID) && !transaction.isRefund) {
                    Button {
                        transaction.processRefund()
                    } label: {
                        Label("Refund", systemImage: "arrowshape.turn.up.left")
                            .accessibility(label: Text("Refund"))
                    }
                }
                Button {
                    self.send = true
                } label: {
                    Label("Email receipt", systemImage: "envelope")
                        .accessibility(label: Text("Email receipt"))
                }
                Button {
                    session.shoppingCart.add(merchantUUID: session.merchantUUID ?? "", cartItems: transaction.purchaseDetail ?? [])
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Label("Repeat", systemImage: "repeat")
                        .accessibility(label: Text("Repeat"))
                }
            }
            Spacer()
            Text(WayPay.formatPrice(transaction.amount))
                .fontWeight(.medium)
        }
        .padding()
        .sheet(isPresented: self.$send) {
            VStack(alignment: .center, spacing: WayPay.UI.verticalSeparation) {
                Text("Email receipt to:")
                    .font(.title)
                TextField("Email", text: self.$email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(.bottom, WayPay.UI.verticalSeparation)
                    .modifier(WayPay.ClearButton(text: $email))
                Button(action: {
                    WayPay.SendEmail.process(transaction: self.transaction, sendTo: self.email)
                    DispatchQueue.main.async {
                        self.send = false
                    }
                 }) {
                     Text("Send")
                         .font(.headline)
                         .fontWeight(.heavy)
                         .foregroundColor(.white)
                 }
                .frame(maxWidth: .infinity, minHeight: WayPay.UI.buttonHeight)
                .background(self.shouldSendEmailButtonBeDisabled ? .gray : Color("MintGreen"))
                .cornerRadius(WayPay.UI.buttonCornerRadius)
                .padding(.bottom, self.keyboardObserver.keyboardHeight)
                .disabled(self.shouldSendEmailButtonBeDisabled)
            }.padding()
        }
    }
}

struct TransactionRowView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionRowView(transaction: WayPay.PaymentTransaction(amount: 100))
    }
}
