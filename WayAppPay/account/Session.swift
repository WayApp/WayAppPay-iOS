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
                    WayAppUtils.Log.message("********************** Session: didSet account")
                    showAuthenticationView = false
                    doesUserHasMerchantAccount = false
                    Merchant.getMerchantsForAccount(account.accountUUID)
                    Card.getCards(for: account.accountUUID)
                }
            }
        }
        @Published var cards = Container<Card>()
        @Published var issuers = Container<Issuer>()
        @Published var merchants = Container<Merchant>()
        @Published var seletectedMerchant: Int = 0 {
            didSet {
                if !merchants.isEmpty && doesUserHasMerchantAccount {
                    Product.loadForMerchant(merchants[seletectedMerchant].merchantUUID)
                    merchants[seletectedMerchant].getAccounts()
                    merchants[seletectedMerchant].getReportID(for: session.accountUUID, month: ReportID.idReportForMonth(Date()))
                    merchants[seletectedMerchant].getTransactionsForAccountForDay(session.accountUUID, day: Calendar.current.date(byAdding: .day, value: 0, to: Date())!)
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
        @Published var selectedTab: MainView.Tab = .cards
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
                self.showAuthenticationView = false
            }
            if let data = UserDefaults.standard.data(forKey: WayAppPay.DefaultKey.CARDS.rawValue),
               let cards = try? WayAppPay.jsonDecoder.decode(Container<Card>.self, from: data) {
                self.cards.setTo(cards)
            } else {
                WayAppUtils.Log.message("********************** ERROR  Loading cards from WayAppPay.DefaultKey.CARDS.rawValue")
            }
            if PKPassLibrary.isPassLibraryAvailable() {
                passes = pkLibrary.passes()
                passes = passes.filter({
                    $0.passTypeIdentifier == "pass.com.wayapp.pay"
                })
                WayAppUtils.Log.message("++++++++ PASSES count=\(passes.count), passes=\(passes)")
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
        
        private func reset() {
            showAuthenticationView = true
            doesUserHasMerchantAccount = false
            selectedAccount = 0
            account = nil
            accounts.empty()
            seletectedMerchant = 0
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
            session.reset()
            do {
                try Account.deletePassword(password, forEmail: email)
            } catch {
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }
    }
}
