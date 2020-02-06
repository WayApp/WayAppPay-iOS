//
//  TransactionsView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 2/3/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject var session: WayAppPay.Session

    var body: some View {
        List {
            ForEach(session.transactions) { transaction in
                TransactionRowView(transaction: transaction)
            }
        }
    }
}

struct TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsView()
    }
}
