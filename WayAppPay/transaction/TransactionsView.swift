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
    @State var monthSelection = Calendar.current.component(.month, from: Date()) - 1
    

    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("This month")) {
                    HStack {
                        Text("Sales: \(WayAppPay.priceFormatter(session.thisMonthReportID?.totalSales))")
                        Text("Sales: \(session.transactions.filter(satisfying: { ($0.amount ?? 0) > 0 }).reduce(0, {$0 + ($1.amount ?? 0) }))")
                        Text("Refunds: \(WayAppPay.priceFormatter(session.thisMonthReportID?.totalRefund))")
                    }
                    Picker(selection: $monthSelection, label: Text("Select another month")) {
                        ForEach(0..<months.count) {
                             Text(self.months[$0])
                         }
                    }
                }
                Section(header: Text("Transactions")) {
                    if session.thisMonthReportID?.totalPerDay != nil {
                        HStack(alignment: .center, spacing: CGFloat(10))
                        {
                            ForEach(0..<(session.thisMonthReportID?.totalPerDay?.count)!) { index in
                                BarView(value: CGFloat(self.session.thisMonthReportID!.totalPerDay![index] / 100), cornerRadius: 2.0)
                            }
                        }.padding(.top, 24).animation(.default)
                        
                    }
                    List {
                        ForEach(session.transactions.filter(satisfying: {
                            if let transactiondate = $0.creationDate {
                                return (((Calendar.current.component(.month, from: transactiondate) - 1) == self.monthSelection) &&
                                    (Calendar.current.component(.year, from: transactiondate) == Calendar.current.component(.year, from: Date())))
                            }
                            return false
                        })) { transaction in
                            TransactionRowView(transaction: transaction)
                        }
                    }
                }
            }
            .navigationBarTitle("Transactions")
        }
    }
}

struct TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsView()
    }
}
