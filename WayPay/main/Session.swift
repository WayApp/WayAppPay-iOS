//
//  Session.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import SwiftUI
import PassKit

extension WayPayApp {

    final class Session: ObservableObject {
        lazy var pkLibrary = PKPassLibrary()
        var passes = [PKPass]()
        var accountUUID: String? { return account?.accountUUID }
        var email: String? { return account?.email }
        var merchantUUID: String? { return merchant?.merchantUUID }

        init() {
            // Check for existance of Merchant must be prior to Account check
            if let merchant = WayPay.Merchant.load(defaultKey: WayPay.DefaultKey.MERCHANT.rawValue, type: WayPay.Merchant.self) {
                Logger.message("Merchant found in defaultKey: WayPay.DefaultKey.MERCHANT=\(merchant)")
                self.merchant = merchant
            }
            // Check for Account existance follows check for Merchant
            if let account = WayPay.Account.load(defaultKey: WayPay.DefaultKey.ACCOUNT.rawValue, type: WayPay.Account.self) {
                self.account = account
            }
            if (OperationMode.shouldRetrievePasses && PKPassLibrary.isPassLibraryAvailable()) {
                passes = pkLibrary.passes()
                passes = passes.filter({
                    $0.passTypeIdentifier == WayPay.passTypeIdentifier
                })
            }
        }
        var banks = Container<AfterBanks.SupportedBank>()
        var issuers = Container<WayPay.Issuer>()
        @Published var cards = Container<WayPay.Card>()
        @Published var showAuthenticationView: Bool = true
        @Published var showAccountHasNoMerchantsAlert: Bool = false
        @Published var showAccountPendingActivationAlert: Bool = false
        @Published var selectedPrize: Int = -1
        //TODO: review the need to use @Published for these variables
        var campaigns = Container<WayPay.Campaign>()
        @Published var transactions = Container<WayPay.PaymentTransaction>()
        @Published var checkin: WayPay.Checkin? {
            didSet {
                if checkin == nil {
                    selectedPrize = -1
                }
            }
        }
        
        @Published var account: WayPay.Account? {
            didSet {
                if let account = account {
                    if merchant == nil {
                        Logger.message("Getting merchant")
                        WayPay.Merchant.getMerchantsForAccount(account.accountUUID) { merchants, error in
                            DispatchQueue.main.async {
                                if let merchants = merchants,
                                   !merchants.isEmpty,
                                   let merchant = merchants.first,
                                   merchant.isActive {
                                    Logger.message("Found active merchant")
                                    self.merchant = merchants.first
                                    self.merchant?.save()
                                } else {
                                    self.showAccountHasNoMerchantsAlert = true
                                    Logger.message("No merchants found for account")
                                }
                            }
                        }
                    }
                    WayPay.Card.getCards(for: account.accountUUID)
                }
            }
        }
        
        @Published var merchant: WayPay.Merchant? {
            didSet {
                Logger.message("Assigning merchant")
                guard let merchant = merchant else {
                    Logger.message("Assigning merchant NIL")
                    return
                }
                DispatchQueue.main.async {
                    if merchant.isActive {
                        Logger.message("Merchant is active")
                        DispatchQueue.main.async {
                            self.showAuthenticationView = false
                            if let issuerUUID = merchant.communityID {
                                WayPay.Campaign.get(merchantUUID: nil, issuerUUID: issuerUUID) {campaigns, error in
                                    if let campaigns = campaigns {
                                        WayPayApp.session.campaigns.setTo(campaigns)
                                        WayPayApp.session.campaigns.sort(by: <)
                                    } else {
                                        Logger.message("Did not find campaigns")
                                    }
                                }
                            } else {
                                Logger.message("ERROR: merchant missing issuerUUID")
                            }
                        }
                    } else {
                        self.showAccountPendingActivationAlert = true
                    }
                }
            }
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
                    try WayPay.Account.savePassword(pin, forEmail: email)
                } catch {
                    Logger.message(error.localizedDescription)
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
            selectedPrize = -1
            transactions.empty()
            campaigns.empty()
        }
        
        func logout() {
            guard let email = email,
                  let password = WayPay.Account.retrievePassword(forEmail: email)
            else {
                Logger.message("Cannot retrieve saved email or password")
                return
            }
            WayPay.DefaultKey.resetSessionKeys()
            reset()
            do {
                try WayPay.Account.deletePassword(password, forEmail: email)
            } catch {
                Logger.message(error.localizedDescription)
            }
        }
    }
}
