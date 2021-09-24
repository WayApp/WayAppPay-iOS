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
import StoreKit

extension WayPay {
    
    static var session = Session()
    
    final class Session: ObservableObject {
        @Published var storeManager: StoreManager = StoreManager()
        @Published var imageDownloader: ImageDownloader?
        @Published var showAuthenticationView: Bool = true
        @AppStorage("skipOnboarding") var skipOnboarding: Bool = UserDefaults.standard.bool(forKey: WayPay.DefaultKey.SKIP_ONBOARDING.rawValue)
        @Published var doesAccountHasMerchants: Bool = false
        @Published var showAccountHasNoMerchantsAlerts: Bool = false
        @Published var account: Account? {
            didSet {
                if let account = account {
                    /*
                    DispatchQueue.main.async {
                        self.showAuthenticationView = false
                    }
 */
                    Merchant.getMerchantsForAccount(account.accountUUID) { merchants, error in
                        if let merchants = merchants,
                           !merchants.isEmpty {
                            DispatchQueue.main.async {
                                self.showAuthenticationView = false
                                self.doesAccountHasMerchants = true
                                session.merchants.setTo(merchants)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.showAccountHasNoMerchantsAlerts = true
                            }
                            WayAppUtils.Log.message("No merchants")
                        }
                    }
                }
            }
        }
        @Published var merchants = Container<Merchant>() {
            didSet {
                DispatchQueue.main.async {
                    self.seletectedMerchant = UserDefaults.standard.integer(forKey: WayPay.DefaultKey.MERCHANT.rawValue)
                }
            }
        }
        @Published var seletectedMerchant: Int = 0 {
            didSet {
                 if !merchants.isEmpty && doesAccountHasMerchants {
                    imageDownloader = ImageDownloader(imageURL: merchant?.logo, addToCache: true)
                    Product.get(merchants[seletectedMerchant].merchantUUID) {products, error in
                        if let products = products {
                            DispatchQueue.main.async {
                                session.products.setTo(products)
                            }
                        } else {
                            WayAppUtils.Log.message("Could not fetch products")
                        }
                    }
                    Campaign.get(merchantUUID: merchants[seletectedMerchant].merchantUUID, issuerUUID: nil, campaignType: Point.self, format: .POINT) {points, error in
                        if let points = points {
                            DispatchQueue.main.async {
                                session.points.setTo(points)
                                session.campaigns.add(points)
                                session.campaigns.sort(by: <)
                            }
                        } else {
                            WayAppUtils.Log.message("Could not fetch POINT campaigns")
                        }
                    }
                    Campaign.get(merchantUUID: merchants[seletectedMerchant].merchantUUID, issuerUUID: nil, campaignType: Stamp.self, format: .STAMP) {stamps, error in
                        if let stamps = stamps {
                            DispatchQueue.main.async {
                                session.stamps.setTo(stamps)
                                session.campaigns.add(stamps)
                                session.campaigns.sort(by: <)
                            }
                        } else {
                            WayAppUtils.Log.message("Could not fetch STAMP campaigns")
                        }
                    }
                }
            }
        }
        
        var merchant: Merchant? {
            if (merchants.isEmpty) {
                return nil
            }
            return merchants[seletectedMerchant]
        }
                      
        //TODO: review the need to use @Published for these variables
        @Published var issuers = Container<Issuer>()
        @Published var campaigns = Container<Campaign>()
        @Published var products = Container<Product>()
        @Published var points = Container<Point>()
        @Published var stamps = Container<Stamp>()
        @Published var transactions = Container<PaymentTransaction>()
        @Published var shoppingCart = ShoppingCart()
        @Published var thisMonthReportID: ReportID?
        @Published var checkin: Checkin? {
         didSet {
            if checkin == nil {
                selectedPrize = -1
            }
         }
        }
        @Published var selectedPrize: Int = -1
        
        func activeStampCampaign() -> Stamp? {
            return stamps.first
        }

        func activePointCampaign() -> Point? {
            return points.first
        }

        func activeIssuerPointCampaign() -> Point? {
            if let checkin = checkin,
               let issuerPointCampaigns = checkin.issuerPointCampaigns,
               !issuerPointCampaigns.isEmpty {
                return issuerPointCampaigns.first
            }
            return nil
        }

        func activeIssuerStampCampaign() -> Stamp? {
            if let checkin = checkin,
               let issuerStampCampaigns = checkin.issuerStampCampaigns,
               !issuerStampCampaigns.isEmpty {
                return issuerStampCampaigns.first
            }
            return nil
        }

        private var networkMonitor = NWPathMonitor()
        var isNetworkAvailable = false
        
        let pkLibrary = PKPassLibrary()
        var passes = [PKPass]()

        init() {
            storeManager.receiptValidation()
            self.networkMonitor.pathUpdateHandler = { path in
                self.isNetworkAvailable = (path.status == .satisfied)
            }
            if let account = Account.load(defaultKey: WayPay.DefaultKey.ACCOUNT.rawValue, type: Account.self) {
                self.account = account
            }
            SKPaymentQueue.default().add(storeManager)
            storeManager.getProducts(productIDs: StoreManager.ProductID.allIDs)
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
                UserDefaults.standard.set(account.email, forKey: WayPay.DefaultKey.EMAIL.rawValue)
                // Saves password
                do {
                    try Account.savePassword(pin, forEmail: email)
                } catch {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
                UserDefaults.standard.synchronize()
            }
        }
        
        func saveSelectedMerchant() {
            UserDefaults.standard.set(seletectedMerchant, forKey: WayPay.DefaultKey.MERCHANT.rawValue)
            UserDefaults.standard.synchronize()
        }
        
        private func reset() {
            showAuthenticationView = true
            doesAccountHasMerchants = false
            account = nil
            checkin = nil
            merchants.empty()
            transactions.empty()
            products.empty()
            shoppingCart.empty()
            points.empty()
            stamps.empty()
            campaigns.empty()
        }
        
        func logout() {
            guard let email = email,
                let password = Account.retrievePassword(forEmail: email)
                else {
                    WayAppUtils.Log.message("Cannot retrieve saved email or password")
                    return
            }
            WayPay.DefaultKey.resetSessionKeys()
            reset()
            do {
                try Account.deletePassword(password, forEmail: email)
            } catch {
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }
    }
}
