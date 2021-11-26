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
    @State private var refundResultAlert = false
    @State private var wasTransactionSuccessful = false
    @State private var send = false
    @State var email: String = UserDefaults.standard.string(forKey: WayPay.DefaultKey.EMAIL.rawValue) ?? ""

    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    var shouldSendEmailButtonBeDisabled: Bool {
        return !WayAppUtils.validateEmail(email)
    }

    @ObservedObject private var keyboardObserver = WayPay.KeyboardObserver()

    var body: some View {
        HStack {
            Image(systemName: transaction.type?.icon ?? "questionmark.square.fill")
                .foregroundColor(Color.green)
            VStack(alignment: .leading, spacing: 8) {
                Text(transaction.type?.title ?? WayPay.PaymentTransaction.TransactionType.defaultTitle)
                Text(transaction.lastUpdateDate != nil ? TransactionRowView.dateFormatter.string(from: transaction.lastUpdateDate!) : "no date")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if !transaction.getPurchaseDetail().isEmpty {
                    Text(transaction.getPurchaseDetail())
                        .font(.footnote)
                }

            }.contextMenu {
                if ((transaction.type == WayPay.PaymentTransaction.TransactionType.SALE && !transaction.isPOSTPAID) && !transaction.isRefund) {
                    Button {
                        transaction.processRefund() { transaction, error in
                            if let transaction = transaction {
                                self.wasTransactionSuccessful = transaction.wasSuccessful
                            } else {
                                self.wasTransactionSuccessful = false
                            }
                            self.refundResultAlert = true
                        }
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
            .alert(isPresented: $refundResultAlert) {
                Alert(
                    title: Text(WayPay.AlertMessage.refund(wasTransactionSuccessful).text.title)
                        .foregroundColor(wasTransactionSuccessful ? Color.green : Color.red)
                        .font(.title),
                    message: Text(WayPay.AlertMessage.refund(wasTransactionSuccessful).text.message),
                    dismissButton: .default(
                        Text(WayPay.SingleMessage.OK.text))
                )
            }
            Spacer()
            Text(WayPay.formatPrice(transaction.amount))
                .bold()
                .foregroundColor(transaction.result == .ACCEPTED ? Color.green : Color.red)
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
                .background(self.shouldSendEmailButtonBeDisabled ? .gray : Color.green)
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
