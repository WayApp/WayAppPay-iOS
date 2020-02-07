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
    var transaction: WayAppPay.Transaction

    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(transaction.creationDate != nil ? TransactionRowView.dateFormatter.string(from: transaction.creationDate!) : "no date")
                Spacer()
                Text("\((transaction.amount != nil ? Double(transaction.amount!) / 100 : 0.00), specifier: "%.2f")")
                //
            }
            Text(transaction.accountUUID != nil ?
                "..." + transaction.accountUUID!.suffix(12) :
                "no account")
            Text((transaction.accountUUID != nil && session.accounts[transaction.accountUUID!] != nil) ?
                session.accounts[transaction.accountUUID!]!.email ?? "no email" :
                "no account")
        }
        .padding()

    }
}

struct TransactionRowView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionRowView(transaction: WayAppPay.Transaction(amount: 1000.0))
    }
}
