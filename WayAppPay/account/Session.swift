//
//  Session.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Combine
import SwiftUI

extension WayAppPay {
    
    final class Session: ObservableObject {
        @Published var account: Account? {
            didSet {
                if let account = account {
                    showAuthenticationView = false
                    Merchant.getMerchantsForAccount(account.accountUUID)
                }
            }
        }
        @Published var merchants = Container<Merchant>()
        @Published var seletectedMerchant: Int = 0 {
            didSet {
                Product.loadForMerchant(merchants[seletectedMerchant].merchantUUID)
                merchants[seletectedMerchant].getAccounts()
                merchants[seletectedMerchant].getReportID(for: session.accountUUID, month: ReportID.idReportForMonth(Date()))
                merchants[seletectedMerchant].getTransactionsForAccountForDay(session.accountUUID, day: Calendar.current.date(byAdding: .day, value: 0, to: Date())!)
            }
        }
        
        enum RefundState {
            case none, success, failure
        }
              
        @Published var refundState: RefundState = .none
        @Published var products = Container<Product>()
        @Published var selectedAccount: Int = 0
        @Published var accounts = Container<Account>()
        @Published var showAuthenticationView: Bool = true
        @Published var selectedTab: MainView.Tab = .amount
        @Published var transactions = Container<PaymentTransaction>()
        @Published var shoppingCart = ShoppingCart()
        @Published var thisMonthReportID: ReportID?
        
        init() {
            if let account = Account.load(defaultKey: WayAppPay.DefaultKey.ACCOUNT.rawValue, type: Account.self) {
                self.account = account
                self.showAuthenticationView = false
            }
        }
        
        var amount: Double {
            var total: Double = 0
            for item in shoppingCart.items {
                total += Double(item.cartItem.quantity) * (Double(item.cartItem.price) / 100)
            }
            return total
        }
        
        var accountUUID: String? {
            return account?.accountUUID
        }

        var email: String? {
            return account?.email
        }

        var merchantUUID: String? {
            return merchants.isEmpty ? nil : merchants[seletectedMerchant].merchantUUID
        }
        
        func saveLoginData(password: String) {
            // Saves account
            if let account = account,
                let email = account.email {
                account.save()
                // Saves email
                UserDefaults.standard.set(account.email, forKey: WayAppPay.DefaultKey.EMAIL.rawValue)
                // Saves password
                do {
                    try Account.savePassword(password, forEmail: email)
                } catch {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
                UserDefaults.standard.synchronize()
            }
        }
        
        func logout() {
            guard let email = email,
                let password = Account.retrievePassword(forEmail: email)
                else {
                    WayAppUtils.Log.message("Cannot retrieve saved email or password")
                    return
            }
            showAuthenticationView = true
            UserDefaults.standard.removeObject(forKey: WayAppPay.DefaultKey.ACCOUNT.rawValue)
            do {
                try Account.deletePassword(password, forEmail: email)
            } catch {
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }
    }

    static var session = Session()

}
