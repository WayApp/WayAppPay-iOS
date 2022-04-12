//
//  CheckinTransactionsView.swift
//  WayPay
//
//  Created by Oscar Anzola on 12/4/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct CheckinTransactionsView: View {
    var transactions: [WayPay.PaymentTransaction]

    var body: some View {
        List {
            ForEach(transactions) { transaction in
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
                    }
                    Spacer()
                    Text(UI.formatPrice(transaction.amount))
                        .bold()
                        .foregroundColor(transaction.result == .ACCEPTED ? Color.green : Color.red)
                }
            }
        }
        .navigationBarTitle(Text("Transactions"), displayMode: .inline)
    }
}

struct CheckinTransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
    }
}
