//
//  TransactionRowView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/6/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct TransactionRowView: View {
    @EnvironmentObject var session: WayAppPay.Session
    var transaction: WayAppPay.PaymentTransaction
    
    @State private var send = false
    
    @State var email: String = UserDefaults.standard.string(forKey: WayAppPay.DefaultKey.EMAIL.rawValue) ?? ""

    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    var shouldSendEmailButtonBeDisabled: Bool {
        return !WayAppUtils.validateEmail(email)
    }

    @ObservedObject private var keyboardObserver = WayAppPay.KeyboardObserver()

    var body: some View {
        HStack {
            transaction.result?.image
            VStack(alignment: .leading, spacing: 8) {
                Text(transaction.creationDate != nil ? TransactionRowView.dateFormatter.string(from: transaction.creationDate!) : "no date")
                Text(transaction.type?.title ?? WayAppPay.PaymentTransaction.TransactionType.defaultTitle)
                Text((transaction.accountUUID != nil && session.accounts[transaction.accountUUID!] != nil) ?
                    session.accounts[transaction.accountUUID!]!.email ?? "no email" :
                    "no account")
                    .font(.subheadline)
            }.contextMenu {
                if ((transaction.type == WayAppPay.PaymentTransaction.TransactionType.SALE && !transaction.isPOSTPAID) && !transaction.isRefund) {
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

            }
            Spacer()
            Text(WayAppPay.formatPrice(transaction.amount))
                .fontWeight(.medium)
        }
        .padding()
        .sheet(isPresented: self.$send) {
            VStack(alignment: .center, spacing: WayAppPay.UI.verticalSeparation) {
                Text("Email receipt to:")
                    .font(.title)
                TextField("Email", text: self.$email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(.bottom, WayAppPay.UI.verticalSeparation)
                    .modifier(WayAppPay.TextFieldModifier())
                    .modifier(WayAppPay.ClearButton(text: $email))
                Button(action: {
                    WayAppPay.SendEmail.process(transaction: self.transaction, sendTo: self.email)
                    DispatchQueue.main.async {
                        self.send = false
                    }
                 }) {
                     Text("Send")
                         .font(.headline)
                         .fontWeight(.heavy)
                         .foregroundColor(.white)
                 }
                .frame(maxWidth: .infinity, minHeight: WayAppPay.UI.buttonHeight)
                .background(self.shouldSendEmailButtonBeDisabled ? .gray : Color("WAP-GreenDark"))
                .cornerRadius(WayAppPay.UI.buttonCornerRadius)
                .padding(.bottom, self.keyboardObserver.keyboardHeight)
                .disabled(self.shouldSendEmailButtonBeDisabled)
            }.padding()
        }
    }
}

struct TransactionRowView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionRowView(transaction: WayAppPay.PaymentTransaction(amount: 100))
    }
}
