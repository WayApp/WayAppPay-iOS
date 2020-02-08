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

    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    var body: some View {
        HStack {
            if transaction.result == .ACCEPTED {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color.green)
            } else {
                Image(systemName: "x.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color.red)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(transaction.creationDate != nil ? TransactionRowView.dateFormatter.string(from: transaction.creationDate!) : "no date")
                Text(transaction.pan != nil ?
                    "PAN: ..." + transaction.pan!.suffix(12) :
                    "no account")
                Text((transaction.accountUUID != nil && session.accounts[transaction.accountUUID!] != nil) ?
                    session.accounts[transaction.accountUUID!]!.email ?? "no email" :
                    "no account")
            }
            Spacer()
            Text(WayAppPay.priceFormatter(transaction.amount))
                .fontWeight(.medium)
        }
        .padding()

    }
}

struct TransactionRowView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionRowView(transaction: WayAppPay.PaymentTransaction(amount: 100))
    }
}
