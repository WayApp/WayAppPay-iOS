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
        
        init() {
            self.networkMonitor.pathUpdateHandler = { path in
                self.isNetworkAvailable = (path.status == .satisfied)
            }
            if let merchant = Merchant.load(defaultKey: WayPay.DefaultKey.MERCHANT.rawValue, type: Merchant.self) {
                WayAppUtils.Log.message("Merchant found in defaultKey: WayPay.DefaultKey.MERCHANT=\(merchant)")
                self.merchant = merchant
            } else {
                WayAppUtils.Log.message("Merchant NOT found in defaultKey: WayPay.DefaultKey.MERCHANT")
            }
            if let account = Account.load(defaultKey: WayPay.DefaultKey.ACCOUNT.rawValue, type: Account.self) {
                self.account = account
            }
        }

        @Published var imageDownloader: ImageDownloader?
        @Published var showAuthenticationView: Bool = true
        @AppStorage("skipOnboarding") var skipOnboarding: Bool = UserDefaults.standard.bool(forKey: WayPay.DefaultKey.SKIP_ONBOARDING.rawValue)
        @Published var showAccountHasNoMerchantsAlerts: Bool = false
        @Published var showAccountPendingActivationAlert: Bool = false
        @Published var thisMonthReportID: ReportID?
        @Published var selectedPrize: Int = -1
        //TODO: review the need to use @Published for these variables
        var campaigns = Container<Campaign>()
        @Published var transactions = Container<PaymentTransaction>()
        @Published var checkin: Checkin? {
         didSet {
            if checkin == nil {
                selectedPrize = -1
            }
         }
        }

        @Published var account: Account? {
            didSet {
                if let account = account {
                    if merchant == nil {
                        WayAppUtils.Log.message("Getting merchant")
                        Merchant.getMerchantsForAccount(account.accountUUID) { merchants, error in
                            DispatchQueue.main.async {
                                if let merchants = merchants,
                                   !merchants.isEmpty,
                                   let merchant = merchants.first,
                                   merchant.isActive {
                                    WayAppUtils.Log.message("Found active merchant")
                                    self.merchant = merchants.first
                                    self.merchant?.save()
                                } else {
                                    self.showAccountHasNoMerchantsAlerts = true
                                    WayAppUtils.Log.message("No merchants")
                                }
                            }
                        }
                    }
                }
            }
        }
        
        @Published var merchant: Merchant? {
            didSet {
                WayAppUtils.Log.message("Assigning merchant")
                guard let merchant = merchant else {
                    return
                }
                DispatchQueue.main.async {
                    if merchant.isActive {
                        WayAppUtils.Log.message("Merchant is active")
                        DispatchQueue.main.async {
                            self.showAuthenticationView = false
                            self.imageDownloader = ImageDownloader(imageURL: merchant.logo, addToCache: true)
                            if let issuerUUID = merchant.issuerUUID {
                                Campaign.get(merchantUUID: nil, issuerUUID: issuerUUID) {campaigns, error in
                                    if let campaigns = campaigns {
                                        session.campaigns.setTo(campaigns)
                                        session.campaigns.sort(by: <)
                                    } else {
                                        WayAppUtils.Log.message("Could not fetch POINT campaigns")
                                    }
                                }
                            } else {
                                WayAppUtils.Log.message("ERROR: merchant missing issuerUUID")
                            }
                        }
                    } else {
                        self.showAccountPendingActivationAlert = true
                    }
                }
            }
        }
                
        private var networkMonitor = NWPathMonitor()
        var isNetworkAvailable = false
        
        let pkLibrary = PKPassLibrary()
        var passes = [PKPass]()
                
        var accountUUID: String? {
            return account?.accountUUID
        }

        var email: String? {
            return account?.email
        }

        var merchantUUID: String? {
            return merchant?.merchantUUID
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
                
        private func reset() {
            showAuthenticationView = true
            showAccountPendingActivationAlert = false
            merchant = nil
            account = nil
            checkin = nil
            transactions.empty()
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
