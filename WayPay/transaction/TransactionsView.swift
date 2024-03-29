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
    @EnvironmentObject private var session: WayPay.Session

    @State var monthSelection = Calendar.current.component(.month, from: Date()) - 1
    @State private var isAPICallOngoing = false
    @State private var transactions = Container<WayPay.PaymentTransaction>()
    @State private var reportID = WayPay.ReportID()
    @State private var refundState: RefundState = .none
    var accountUUID: String?

    private func fillReportID() {
        reportID.reset()
        for transaction in transactions where transaction.result == .ACCEPTED {
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
    
    private var isCustomerDisplayMode: Bool {
        return accountUUID != nil
    }

    var body: some View {
        ZStack {
            Form {
                if (!isCustomerDisplayMode) {
                    Section(header: Text("This month")) {
                        VStack(alignment: .leading) {
                            HStack {
                                Label("Sales", systemImage: "arrow.up.square")
                                    .accessibility(label: Text("Sales"))
                                Text("\(WayPay.formatPrice(reportID.totalSales ?? 0))")
                            }
                            HStack {
                                Label("Refunds", systemImage: "arrow.down.square")
                                    .accessibility(label: Text("Refunds"))
                                Text("\(WayPay.formatPrice(reportID.totalRefund ?? 0))")
                            }
                        }
                        Picker(selection: $monthSelection, label: Text("Select another month:")) {
                            ForEach(0..<Month.allCases.count) {
                                Text(Month(rawValue: $0)?.title ?? "month")
                            }
                        }
                        .onChange(of: monthSelection, perform: { month in
                            WayAppUtils.Log.message("initialDate=\(Month(rawValue: monthSelection)?.firstDay), finalDate=\(Month(rawValue: monthSelection)?.lastDay), monthSelection=\(monthSelection)")
                            if let accountUUID = session.accountUUID {
                                session.merchants[session.seletectedMerchant].getTransactionsForAccountByDates(accountUUID: accountUUID, initialDate: Month(rawValue: monthSelection)?.firstDay, finalDate: Month(rawValue: monthSelection)?.lastDay) { transactions, error in
                                    WayAppUtils.Log.message("TRANSACTIONS COUNT=\(transactions?.count)")
                                    if let transactions = transactions {
                                        DispatchQueue.main.async {
                                            self.transactions.setToInOrder(transactions, by:
                                                { ($0.lastUpdateDate ?? Date.distantPast) > ($1.lastUpdateDate ?? Date.distantPast) })
                                            fillReportID()
                                        }
                                    }
                                }

                            }
                        })
                    }
                }
                Section(header: Text(isCustomerDisplayMode ? "" : NSLocalizedString("Transactions", comment: "TransactionsView section header"))) {
                    List {
                        ForEach(transactions.filter(satisfying: {
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
                if (accountUUID == nil) {
                    WayAppUtils.Log.message("onAppear")
                    let firstDayOfMonth = Month(rawValue: monthSelection)?.firstDay
                    let lastDayOfMonth = Month(rawValue: monthSelection)?.lastDay
                    DispatchQueue.main.async {
                        isAPICallOngoing = false
                    }
                    if let accountUUID = session.accountUUID {
                        session.merchants[session.seletectedMerchant].getTransactionsForAccountByDates(accountUUID: accountUUID,
                                                                                                       initialDate: firstDayOfMonth, finalDate: lastDayOfMonth) { transactions, error in
                            if let transactions = transactions {
                                DispatchQueue.main.async {
                                    self.transactions.setToInOrder(transactions, by:
                                        { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) })
                                    fillReportID()
                                }
                            }
                        }
                    }
                } else {
                    getTransactions()
                }
            })
            .navigationBarTitle("Transactions")
            .background(Color("CornSilk"))
            .edgesIgnoringSafeArea(.all)
            if refundState != .none {
                Image(systemName: refundState == .success ? WayPay.UI.paymentResultSuccessImage : WayPay.UI.paymentResultFailureImage)
                    .resizable()
                    .foregroundColor(refundState == .success ? Color.green : Color.red)
                    .frame(width: WayPay.UI.paymentResultImageSize, height: WayPay.UI.paymentResultImageSize, alignment: .center)
            }
            if isAPICallOngoing {
                ProgressView(NSLocalizedString("Please wait…", comment: "Activity indicator"))
            }
        }
    }
    
    private func getTransactions() {
        WayAppUtils.Log.message("Entering")
        guard let merchantUUID = session.merchantUUID,
              let accountUUID = accountUUID else {
            WayAppUtils.Log.message("Missing session.merchantUUID or session.accountUUID")
            return
        }
        let finalDate = Date()
        let daysAgo = -3
        let initialDate = Calendar.current.date(byAdding: .day, value: daysAgo, to: finalDate)
        WayAppUtils.Log.message("initialDate: \(WayPay.reportDateFormatter.string(from: initialDate!))")
        if let initialDate = initialDate {
            WayPay.Account.transactions(merchantUUID: merchantUUID, accountUUID: accountUUID, initialDate: WayPay.reportDateFormatter.string(from: initialDate), finalDate: WayPay.reportDateFormatter.string(from: finalDate)) {
                transactions, error in
                    if let transactions = transactions {
                        WayAppUtils.Log.message("TRANSACTIONS COUNT=\(transactions.count)")
                        DispatchQueue.main.async {
                            self.transactions.setToInOrder(transactions, by:
                                { ($0.lastUpdateDate ?? Date.distantPast) > ($1.lastUpdateDate ?? Date.distantPast) })
                        }
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
