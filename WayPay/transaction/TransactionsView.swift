//
//  TransactionsView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 2/3/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

enum RefundState {
    case none, success, failure
}

enum Month: Int, CaseIterable {
    case January, February, March, April, May, June, July, August, September, October, November, December
    
    var title: String {
        switch self {
        case .January: return NSLocalizedString("January", comment: "month of the year")
        case .February: return NSLocalizedString("February", comment: "month of the year")
        case .March: return NSLocalizedString("March", comment: "month of the year")
        case .April: return NSLocalizedString("April", comment: "month of the year")
        case .May: return NSLocalizedString("May", comment: "month of the year")
        case .June: return NSLocalizedString("June", comment: "month of the year")
        case .July: return NSLocalizedString("July", comment: "month of the year")
        case .August: return NSLocalizedString("August", comment: "month of the year")
        case .September: return NSLocalizedString("September", comment: "month of the year")
        case .October: return NSLocalizedString("October", comment: "month of the year")
        case .November: return NSLocalizedString("November", comment: "month of the year")
        case .December: return NSLocalizedString("December", comment: "month of the year")
        }
    }
    
    var firstDay: String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let yearString = dateFormatter.string(from: date)
        switch self {
        case .January: return yearString + "-01-01"
        case .February: return yearString + "-02-01"
        case .March: return yearString + "-03-01"
        case .April: return yearString + "-04-01"
        case .May: return yearString + "-05-01"
        case .June: return yearString + "-06-01"
        case .July: return yearString + "-07-01"
        case .August: return yearString + "-08-01"
        case .September: return yearString + "-09-01"
        case .October: return yearString + "-10-01"
        case .November: return yearString + "-11-01"
        case .December: return yearString + "-12-01"
        }
    }
    
    var lastDay: String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let yearString = dateFormatter.string(from: date)
        switch self {
        case .January: return yearString + "-01-31"
        case .February: return yearString + "-02-29"
        case .March: return yearString + "-03-31"
        case .April: return yearString + "-04-30"
        case .May: return yearString + "-05-31"
        case .June: return yearString + "-06-30"
        case .July: return yearString + "-07-31"
        case .August: return yearString + "-08-31"
        case .September: return yearString + "-09-30"
        case .October: return yearString + "-10-31"
        case .November: return yearString + "-11-30"
        case .December: return yearString + "-12-31"
        }
    }
}

struct TransactionsView: View {
    @EnvironmentObject private var session: WayPayApp.Session

    @State var monthSelection = Calendar.current.component(.month, from: Date()) - 1
    @State private var isAPICallOngoing = false
    @State private var reportID = WayPay.ReportID()
    @State private var refundState: RefundState = .none
    @State private var transactions = Container<WayPay.PaymentTransaction>()

    var checkin: WayPay.Checkin?

    private func fillReportID() {
        reportID.reset()
        for transaction in self.transactions where transaction.result == .ACCEPTED {
            switch transaction.type {
            case .SALE:
                reportID.totalSales! += (transaction.amount ?? 0)
            case .REFUND:
                reportID.totalRefund! += (transaction.amount ?? 0)
            default:
                break
            }
        }
    }
    
    private var isCheckinDisplayMode: Bool {
        return checkin != nil && checkin?.accountUUID != nil
    }

    var body: some View {
        ZStack {
            Form {
                if (!isCheckinDisplayMode) {
                    Section(header: Text("This month")) {
                        VStack(alignment: .leading) {
                            HStack {
                                Label("Sales", systemImage: "plus.square")
                                    .accessibility(label: Text("Sales"))
                                Text("\(UI.formatPrice(reportID.totalSales ?? 0))")
                                    .bold()
                            }
                            HStack {
                                Label("Refunds", systemImage: "minus.square")
                                    .accessibility(label: Text("Refunds"))
                                Text("\(UI.formatPrice(reportID.totalRefund ?? 0))")
                                    .bold()
                                    .foregroundColor(Color.red)
                            }
                        }
                        Picker(selection: $monthSelection, label: Text("Month" + ":")) {
                            ForEach(0..<Month.allCases.count,  id:\.self) {
                                Text(Month(rawValue: $0)?.title ?? "month")
                            }
                        }
                        .onChange(of: monthSelection, perform: { month in
                            if let accountUUID = session.accountUUID,
                               let merchant = session.merchant {
                                merchant.getTransactionsForAccountByDates(accountUUID: accountUUID, initialDate: Month(rawValue: monthSelection)?.firstDay, finalDate: Month(rawValue: monthSelection)?.lastDay) { transactions, error in
                                    if let transactions = transactions {
                                        DispatchQueue.main.async {
                                            self.transactions.setToInOrder(transactions, by:
                                                { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) })
                                            fillReportID()
                                        }
                                    }
                                }

                            }
                        })
                    }
                }
                Section(header: Text(isCheckinDisplayMode ? "" : NSLocalizedString("Transactions", comment: "TransactionsView section header"))) {
                    List {
                        ForEach(self.transactions.filter(satisfying: {
                            if (isCheckinDisplayMode) {
                                return true
                            }
                            if let transactiondate = $0.lastUpdateDate {
                                return (((Calendar.current.component(.month, from: transactiondate) - 1) == self.monthSelection) &&
                                            (Calendar.current.component(.year, from: transactiondate) == Calendar.current.component(.year, from: Date())))
                            }
                            return false
                        })) { transaction in
                            TransactionRowView(transaction: transaction)
                        }
                    } // List
                } // Section
            } // Form
            .onAppear(perform: {
                if (isCheckinDisplayMode) {
                    getCheckinTransactions()
                } else {
                    Logger.message("onAppear")
                    let firstDayOfMonth = Month(rawValue: monthSelection)?.firstDay
                    let lastDayOfMonth = Month(rawValue: monthSelection)?.lastDay
                    DispatchQueue.main.async {
                        isAPICallOngoing = false
                    }
                    if let accountUUID = session.accountUUID,
                       let merchant = session.merchant {
                        merchant.getTransactionsForAccountByDates(accountUUID: accountUUID, initialDate: firstDayOfMonth, finalDate: lastDayOfMonth) { transactions, error in
                            if let transactions = transactions {
                                DispatchQueue.main.async {
                                    self.transactions.setToInOrder(transactions, by:
                                        { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) })
                                    fillReportID()
                                }
                            }
                        }
                    }
                }
            })
            .navigationBarTitle("Transactions")
            if refundState != .none {
                Image(systemName: refundState == .success ? UI.Constant.paymentResultSuccessImage : UI.Constant.paymentResultFailureImage)
                    .resizable()
                    .foregroundColor(refundState == .success ? Color.green : Color.red)
                    .frame(width: UI.Constant.paymentResultImageSize, height: UI.Constant.paymentResultImageSize, alignment: .center)
            }
            if isAPICallOngoing {
                ProgressView(NSLocalizedString(WayPay.SingleMessage.progressView.text, comment: "Activity indicator"))
                    .progressViewStyle(UI.WayPayProgressViewStyle())
            }
        }
    }
    
    private func getCheckinTransactions() {
        guard let checkin = checkin,
              let transactions = checkin.transactions else {
            return
        }
        self.transactions.setToInOrder(transactions, by:
            { ($0.lastUpdateDate ?? Date.distantPast) > ($1.lastUpdateDate ?? Date.distantPast) })
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
        .environmentObject(WayPayApp.session)
    }
}
