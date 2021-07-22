//
//  TransactionsView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 2/3/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject var session: WayPay.Session
    @State var monthSelection = Calendar.current.component(.month, from: Date()) - 1
    @State private var isAPICallOngoing = false

    private func reportByDates(newMonthSelection: Int) -> (Date, Date) {
        var day = Date()
        var initialComponents = DateComponents()
        var initialDate: Date
        var endDate: Date
        var endComponents = DateComponents()
        let currentMonth = Calendar.current.component(.month, from: day) - 1

        WayAppUtils.Log.message("currentMonth=\(currentMonth), newMonthSelection=\(newMonthSelection)")
        if newMonthSelection <= currentMonth {
            day = Calendar.current.date(byAdding: .month, value: (newMonthSelection - currentMonth), to: day)!
            initialComponents = Calendar.current.dateComponents([.year, .month], from: day)
        } else if newMonthSelection > currentMonth {
            day = Calendar.current.date(byAdding: .month, value: (newMonthSelection - monthSelection), to: Date())!
            day = Calendar.current.date(byAdding: .year, value: -1, to: day)!
        }
        initialDate = Calendar.current.date(from: initialComponents)!
        endComponents.month = 1
        endComponents.second = -1
        endDate = Calendar.current.date(byAdding: endComponents, to: initialDate)!
        WayAppUtils.Log.message("day=\(day), initialDate=\(initialDate), endDate=\(endDate)")
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

    private func fillReportID() {
        var reportID = WayPay.ReportID()
        
        for transaction in session.transactions where transaction.result == .ACCEPTED {
            switch transaction.type {
            case .SALE:
                reportID.totalSales! += (transaction.amount ?? 0)
            case .REFUND:
                reportID.totalRefund! += (transaction.amount ?? 0)
            default:
                break
            }
        }
        session.thisMonthReportID = reportID
    }

    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section(header: Text("This month")) {
                        VStack(alignment: .leading) {
                            HStack {
                                Label("Sales", systemImage: "arrow.up.square")
                                    .accessibility(label: Text("Sales"))
                                Text("\(WayPay.formatPrice(session.thisMonthReportID?.totalSales ?? 0))")
                            }
                            HStack {
                                Label("Refunds", systemImage: "arrow.down.square")
                                    .accessibility(label: Text("Refunds"))
                                Text("\(WayPay.formatPrice(session.thisMonthReportID?.totalRefund ?? 0))")
                            }
                        }
                        Picker(selection: $monthSelection, label: Text("Select another month:")) {
                            ForEach(0..<months.count) {
                                Text(self.months[$0].0)
                            }
                        }
                        .onChange(of: monthSelection, perform: { month in
                            let dates: (Date, Date) = reportByDates(newMonthSelection: monthSelection)
                            WayAppUtils.Log.message("initialDate=\(dates.0), finalDate=\(dates.1), monthSelection=\(monthSelection)")
                            if let accountUUID = session.accountUUID {
                                session.merchants[session.seletectedMerchant].getTransactionsForAccountByDates(accountUUID: accountUUID, initialDate: dates.0, finalDate: dates.1) { transactions, error in
                                    if let transactions = transactions {
                                        DispatchQueue.main.async {
                                            session.transactions.setToInOrder(transactions, by:
                                                { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) })
                                            fillReportID()
                                        }
                                    }
                                }

                            }
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
                .onAppear(perform: {
                    let today = Date()
                    let components = Calendar.current.dateComponents([.year, .month], from: today)
                    let firstDayOfMonth = Calendar.current.date(from: components)!
                    DispatchQueue.main.async {
                        isAPICallOngoing = false
                    }
                    if let accountUUID = session.accountUUID {
                        session.merchants[session.seletectedMerchant].getTransactionsForAccountByDates(accountUUID: accountUUID,
                                                                                                       initialDate: firstDayOfMonth, finalDate: today) { transactions, error in
                            if let transactions = transactions {
                                DispatchQueue.main.async {
                                    session.transactions.setToInOrder(transactions, by:
                                        { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) })
                                    fillReportID()
                                }
                            }
                        }
                    }
                })
                .navigationBarTitle("Transactions")
                if session.refundState != .none {
                    Image(systemName: session.refundState == .success ? WayPay.UI.paymentResultSuccessImage : WayPay.UI.paymentResultFailureImage)
                        .resizable()
                        .foregroundColor(session.refundState == .success ? Color.green : Color.red)
                        .frame(width: WayPay.UI.paymentResultImageSize, height: WayPay.UI.paymentResultImageSize, alignment: .center)
                }
                if isAPICallOngoing {
                    ProgressView(NSLocalizedString("Please wait…", comment: "Activity indicator"))
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
        .environmentObject(WayPay.session)
    }
}
