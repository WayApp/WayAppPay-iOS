//
//  Session.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Network
import SwiftUI
import PassKit

extension WayAppPay {
    
    static var session = Session()
    
    final class Session: ObservableObject {
        @Published var banks = Container<AfterBanks.SupportedBank>()
        @Published var account: Account? {
            didSet {
                if let account = account {
//                    Account.registerAccount(registration: Registration(email: "agagagag@wayapp.com", issuerUUID: "f157c0c5-49b4-445a-ad06-70727030b38a"))
                    showAuthenticationView = false
                    doesUserHasMerchantAccount = false
                    Merchant.getMerchantsForAccount(account.accountUUID)
                    // TODO:
//                    Account.delete("f05249fd-4d0e-455b-a89d-8c245e1d4a88")
//                    Account.delete("e57d740d-b914-4fbd-b49f-e91efa4caafa")
                    Card.getCards(for: account.accountUUID)
                    Issuer.get()
//                    AfterBanks.getBanks()
                }
            }
        }
        @Published var cards = Container<Card>()
        @Published var issuers = Container<Issuer>()
        @Published var merchants = Container<Merchant>() {
            didSet {
                DispatchQueue.main.async {
                    self.doesUserHasMerchantAccount = (self.merchants.count > 0)
                    self.seletectedMerchant = UserDefaults.standard.integer(forKey: WayAppPay.DefaultKey.MERCHANT.rawValue)
                }
            }
        }
        @Published var seletectedMerchant: Int = 0 {
            didSet {
                let today = Date()
                let components = Calendar.current.dateComponents([.year, .month], from: today)
                let firstDayOfMonth = Calendar.current.date(from: components)!
                
                if !merchants.isEmpty && doesUserHasMerchantAccount {
                    Product.loadForMerchant(merchants[seletectedMerchant].merchantUUID)
                    merchants[seletectedMerchant].getAccounts()
                    //merchants[seletectedMerchant].getReportID(for: accountUUID, month: ReportID.idReportForMonth(Date()))
                    //merchants[seletectedMerchant].getTransactionsForAccountForDay(accountUUID, day: Calendar.current.date(byAdding: .day, value: 0, to: Date())!)
                    merchants[seletectedMerchant].getTransactionsForAccountByDates(accountUUID, initialDate: firstDayOfMonth, finalDate: today)
                }
            }
        }
        
        enum RefundState {
            case none, success, failure
        }
              
        //TODO: review the need to use @Published for these variables
        @Published var refundState: RefundState = .none
        @Published var products = Container<Product>()
        @Published var selectedAccount: Int = 0
        @Published var accounts = Container<Account>()
        @Published var showAuthenticationView: Bool = true
        @Published var transactions = Container<PaymentTransaction>()
        @Published var shoppingCart = ShoppingCart()
        @Published var thisMonthReportID: ReportID?
        @Published var loginError: Bool = false
        var doesUserHasMerchantAccount: Bool = false

        private var networkMonitor = NWPathMonitor()
        var isNetworkAvailable = false
        
        let pkLibrary = PKPassLibrary()
        var passes = [PKPass]()

        init() {
            self.networkMonitor.pathUpdateHandler = { path in
                self.isNetworkAvailable = (path.status == .satisfied)
            }
            if let account = Account.load(defaultKey: WayAppPay.DefaultKey.ACCOUNT.rawValue, type: Account.self) {
                self.account = account
            }
            if PKPassLibrary.isPassLibraryAvailable() {
                passes = pkLibrary.passes()
                passes = passes.filter({
                    $0.passTypeIdentifier == "pass.com.wayapp.pay"
                })
                WayAppUtils.Log.message("++++++++ PASSES count=\(passes.count), passes=\(passes)")
            }
        }
        
        var amount: Int {
            var total: Int = 0
            for item in shoppingCart.items {
                total += item.cartItem.quantity * item.cartItem.price
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
        
        func saveLoginData(pin: String) {
            // Saves account
            if let account = account,
                let email = account.email {
                account.save()
                // Saves email
                UserDefaults.standard.set(account.email, forKey: WayAppPay.DefaultKey.EMAIL.rawValue)
                // Saves password
                do {
                    WayAppUtils.Log.message("*********SAVING PIN=\(pin)")
                    try Account.savePassword(pin, forEmail: email)
                } catch {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
                UserDefaults.standard.synchronize()
            }
        }
        
        func saveSelectedMerchant() {
            UserDefaults.standard.set(seletectedMerchant, forKey: WayAppPay.DefaultKey.MERCHANT.rawValue)
            UserDefaults.standard.synchronize()
        }
        
        private func reset() {
            showAuthenticationView = true
            doesUserHasMerchantAccount = false
            selectedAccount = 0
            account = nil
            seletectedMerchant = 0
            accounts.empty()
            merchants.empty()
            transactions.empty()
            products.empty()
            shoppingCart.empty()
            cards.empty()
        }
        
        func logout() {
            guard let email = email,
                let password = Account.retrievePassword(forEmail: email)
                else {
                    WayAppUtils.Log.message("Cannot retrieve saved email or password")
                    return
            }
            WayAppPay.DefaultKey.resetSessionKeys()
            reset()
            do {
                try Account.deletePassword(password, forEmail: email)
            } catch {
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }
    }
}
