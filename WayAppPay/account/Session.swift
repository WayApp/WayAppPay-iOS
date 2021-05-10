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
                    // Las Rozas issuerUUID: f157c0c5-49b4-445a-ad06-70727030b38a
                    // Parquesur issuerUUID staging: 6fae922e-9a08-48a8-859d-d9e8a0d54f21
                    // As Cancelas issuerUUID staging: dd5ed363-88ce-4308-9cf2-20f3930d7cfd
//                    Account.registerAccount(registration: Registration(email: "m3@wayapp.com", issuerUUID: "dd5ed363-88ce-4308-9cf2-20f3930d7cfd"))
                    showAuthenticationView = false
                    doesUserHasMerchantAccount = false
                    Merchant.getMerchantsForAccount(account.accountUUID)
                    // TODO:
//                    Account.delete("1e7e11a2-7d9a-4afa-bb66-66d874c9c136")
                    //Card.getCards(for: account.accountUUID)
                    //Issuer.get()
//                    AfterBanks.getBanks()
                    
                    /*
                    Merchant.newSEPAS(initialDate: "2021-04-15", finalDate: "2021-04-21") { transactions, error in
                        if let transactions = transactions {
                            WayAppUtils.Log.message("Transactions count: \(transactions.count)")
                            for transaction in transactions {
                                WayAppUtils.Log.message("Transaction: \(transaction)")
                            }
                        } else if let error = error  {
                            WayAppUtils.Log.message("%%%%%%%%%%%%%% Transaction ERROR: \(error.localizedDescription)")
                        } else {
                            WayAppUtils.Log.message("%%%%%%%%%%%%%% Transaction ERROR: -------------")
                        }
                    }
 */
                    /*
                    Issuer.getTransactions(issuerUUID: "1338193f-c6d9-4c19-a7d8-1c80fe9f017f", initialDate: "2021-04-15", finalDate: "2021-04-19") { transactions, error in
                        if let transactions = transactions {
                            WayAppUtils.Log.message("Transactions count: \(transactions.count)")
                            for transaction in transactions {
                                WayAppUtils.Log.message("Transaction: \(transaction)")
                            }
                        } else if let error = error  {
                            WayAppUtils.Log.message("%%%%%%%%%%%%%% Transaction ERROR: \(error.localizedDescription)")
                        } else {
                            WayAppUtils.Log.message("%%%%%%%%%%%%%% Transaction ERROR: -------------")
                        }
                    }
*/
                    /*
                    Campaign.get(merchantUUID: "", issuerUUID: "100") { campaigns, error in
                        if let campaigns = campaigns {
                            WayAppUtils.Log.message("Campaigns count: \(campaigns.count)")
                            for campaign in campaigns {
                                WayAppUtils.Log.message("Campaign: \(campaign)")
                            }
                        } else if let error = error  {
                            WayAppUtils.Log.message("%%%%%%%%%%%%%% Campaign ERROR: \(error.localizedDescription)")
                        } else {
                            WayAppUtils.Log.message("%%%%%%%%%%%%%% Campaign ERROR: -------------")
                        }
                    }
 */
                    /*
                    Campaign.get(campaignID: "c040399e-ab0b-4b25-ae55-cc12f9bb3c18", sponsorUUID: "100") { campaigns, error in
                        if let campaigns = campaigns {
                            for campaign in campaigns {
                                WayAppUtils.Log.message("Campaign: \(campaign)")
                            }
                        } else if let error = error  {
                            WayAppUtils.Log.message("%%%%%%%%%%%%%% Campaign ERROR: \(error.localizedDescription)")
                        } else {
                            WayAppUtils.Log.message("%%%%%%%%%%%%%% Campaign ERROR: -------------")
                        }
                    }
 */
                    /*
                    let campaign: Campaign = Campaign(name: "C10", sponsorUUID: "100", format: .POINT)
                    Campaign.create(campaign) { campaigns, error in
                        if let campaigns = campaigns {
                            for campaign in campaigns {
                                WayAppUtils.Log.message("Campaign: \(campaign)")
                            }
                        } else if let error = error  {
                            WayAppUtils.Log.message("%%%%%%%%%%%%%% Campaign ERROR: \(error.localizedDescription)")
                        } else {
                            WayAppUtils.Log.message("%%%%%%%%%%%%%% Campaign ERROR: -------------")
                        }
                    }
                    */
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
                if !merchants.isEmpty && doesUserHasMerchantAccount {
                    Product.get(merchants[seletectedMerchant].merchantUUID) {products, error in
                        if let products = products {
                            DispatchQueue.main.async {
                                session.products.setTo(products)
                            }
                        } else {
                            WayAppUtils.Log.message("Could not fetch products")
                        }
                    }
                    merchants[seletectedMerchant].getAccounts()
                    //merchants[seletectedMerchant].getReportID(for: accountUUID, month: ReportID.idReportForMonth(Date()))
                    //merchants[seletectedMerchant].getTransactionsForAccountForDay(accountUUID, day: Calendar.current.date(byAdding: .day, value: 0, to: Date())!)
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
