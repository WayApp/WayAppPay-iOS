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
    @EnvironmentObject var session: WayPayApp.Session
    var transaction: WayPay.PaymentTransaction
    @State private var refundResultAlert = false
    @State private var wasTransactionSuccessful = false
    @State private var send = false
    @State private var showImagePicker = false
    @State private var showTicket = false
    @State var email: String = UserDefaults.standard.string(forKey: WayPay.DefaultKey.EMAIL.rawValue) ?? ""
    @State private var ticket: UIImage? = UIImage(named: WayPay.Merchant.defaultLogo)

    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    var shouldSendEmailButtonBeDisabled: Bool {
        return !WayAppUtils.validateEmail(email)
    }

    @ObservedObject private var keyboardObserver = UI.KeyboardObserver()

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
                Button {
                    self.send = true
                } label: {
                    Label("Email receipt", systemImage: "envelope")
                        .accessibility(label: Text("Email receipt"))
                }
                Button(action: {
                    self.showImagePicker = true
                }, label: {
                    Label(NSLocalizedString("Fotografiar ticket", comment: "photograph sales ticket"), systemImage: "camera.badge.ellipsis")
                        .padding()
                })
                if transaction.ticketURL != nil {
                    Button(action: {
                        self.showTicket = true
                    }, label: {
                        Label(NSLocalizedString("Ver ticket", comment: "view sales ticket"), systemImage: "eye.circle")
                            .padding()
                    })
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
            Text(UI.formatPrice(transaction.amount))
                .bold()
                .foregroundColor(transaction.result == .ACCEPTED ? Color.green : Color.red)
        }
        .padding()
        .sheet(isPresented: self.$send) {
            VStack(alignment: .center, spacing: UI.Constant.verticalSeparation) {
                Text("Email receipt to:")
                    .font(.title)
                TextField(NSLocalizedString("email", comment: "TransactionRowView: TextField"), text: self.$email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(.bottom, UI.Constant.verticalSeparation)
                    .modifier(UI.ClearButton(text: $email))
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
                .frame(maxWidth: .infinity, minHeight: UI.Constant.buttonHeight)
                .background(self.shouldSendEmailButtonBeDisabled ? .gray : Color.green)
                .cornerRadius(UI.Constant.buttonCornerRadius)
                .padding(.bottom, self.keyboardObserver.keyboardHeight)
                .disabled(self.shouldSendEmailButtonBeDisabled)
            }.padding()
        }
        .sheet(isPresented: self.$showImagePicker) {
            PhotoCaptureView(withCameraOn: true, showImagePicker: self.$showImagePicker, image: self.$ticket) {
                saveTicket()
            }
        }
        .sheet(isPresented: self.$showTicket) {
            //ImageView(withURL: transaction.ticketURL)
            //AsyncImage(url: URL(string: transaction.ticketURL!))
            AsyncImage(url: URL(string: transaction.ticketURL!)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.green.opacity(0.1)
            }
//            .frame(width: 400, height: 600)
            .rotationEffect(.degrees(+90))

        }

    }
    
    private func saveTicket() {
        Logger.message("Completion!!!!!!")
        transaction.saveTicket(ticketImage: ticket) { transactions, error in
            if let transactions = transactions,
               let transaction = transactions.first {
                Logger.message("Transaction.transactionUUID Ticket success: \(transaction.transactionUUID ?? "")")
            } else if let error = error  {
                Logger.message("Transaction ticket ERROR: \(error.localizedDescription)")
            } else {
                Logger.message("Transaction ticket ERROR is NIL")
            }
        }

    }

}

struct TransactionRowView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionRowView(transaction: WayPay.PaymentTransaction(amount: 100))
    }
}
