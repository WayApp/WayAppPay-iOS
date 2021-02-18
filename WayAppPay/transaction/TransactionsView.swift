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

    private func reportByDates(newMonthSelection: Int) -> (Date, Date) {
        var day: Date
        var initialComponents = DateComponents()
        var initialDate: Date
        var endDate: Date
        var endComponents = DateComponents()

        if newMonthSelection < monthSelection {
            day = Calendar.current.date(byAdding: .month, value: (monthSelection - newMonthSelection), to: Date())!
            initialComponents = Calendar.current.dateComponents([.year, .month], from: day)
        } else if newMonthSelection > monthSelection {
            day = Calendar.current.date(byAdding: .month, value: (newMonthSelection - monthSelection), to: Date())!
            day = Calendar.current.date(byAdding: .year, value: -1, to: day)!
        }
        initialDate = Calendar.current.date(from: initialComponents)!
        endComponents.month = 1
        endComponents.second = -1
        endDate = Calendar.current.date(byAdding: endComponents, to: initialDate)!
        return((initialDate, endDate))
    }
    
    let months: [(String, String)] = [(NSLocalizedString("January", comment: "month of the year"), "01"),
                                      (NSLocalizedString("February", comment: "month of the year"), "02"),
                                      (NSLocalizedString("March", comment: "month of the year"), "03"),
                                      (NSLocalizedString("April", comment: "month of the year"), "04"),
                                      (NSLocalizedString("May", comment: "month of the year"), "05"),
                                      (NSLocalizedString("June", comment: "month of the year"), "06"),
                                      (NSLocalizedString("July", comment: "month of the year"), "07"),
                                      (NSLocalizedString("August", comment: "month of the year"), "08"),
                                      (NSLocalizedString("September", comment: "month of the year"), "09"),
                                      (NSLocalizedString("October", comment: "month of the year"), "10"),
                                      (NSLocalizedString("November", comment: "month of the year"), "11"),
                                      (NSLocalizedString("December", comment: "month of the year"), "12"),
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section(header: Text("This month")) {
                        VStack {
                            Text("Sales: \(WayAppPay.priceFormatter(session.thisMonthReportID?.totalSales ?? 0))")
                            Text("Refunds: \(WayAppPay.priceFormatter(session.thisMonthReportID?.totalRefund ?? 0))")
                        }
                        Picker(selection: $monthSelection, label: Text("Select another month:")) {
                            ForEach(0..<months.count) {
                                Text(self.months[$0].0)
                            }
                        }
                        .onChange(of: monthSelection, perform: { month in
                            let dates: (Date, Date) = reportByDates(newMonthSelection: monthSelection)
                            WayAppUtils.Log.message("initialDate=\(dates.0), finalDate=\(dates.1), monthSelection=\(monthSelection)")
                            session.merchants[session.seletectedMerchant].getTransactionsForAccountByDates(session.accountUUID, initialDate: dates.0, finalDate: dates.1)
                        })
                    }
                    Section(header: Text("Transactions")) {
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
                    } // Section
                } // Form
                .navigationBarTitle("Transactions")
                if session.refundState != .none {
                    Image(systemName: session.refundState == .success ? WayAppPay.UI.paymentResultSuccessImage : WayAppPay.UI.paymentResultFailureImage)
                        .resizable()
                        .foregroundColor(session.refundState == .success ? Color.green : Color.red)
                        .frame(width: WayAppPay.UI.paymentResultImageSize, height: WayAppPay.UI.paymentResultImageSize, alignment: .center)
                }
            }
            
        }
    }
}

struct TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        //TransactionsView()
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            TransactionsView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
        .environmentObject(WayAppPay.session)
    }
}
