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
                    Merchant.loadMerchantsForAccount(account.accountUUID)
                }
            }
        }
        @Published var seletectedMerchant: Int = 0 {
            didSet {
                Product.loadForMerchant(merchants[seletectedMerchant].merchantUUID)
            }
        }
        
        @Published var merchants = Container<Merchant>()
        @Published var products = Container<Product>()
        
        
        init() {
            print("@@@@@@@@@@@@@@@@@@@@@@@@ INIT @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
            if let account = Account.load(defaultKey: WayAppPay.DefaultKey.ACCOUNT.rawValue, type: Account.self) {
                self.account = account
            }
        }
        
        var accountUUID: String? {
            return account?.accountUUID
        }

        var email: String? {
            return account?.email
        }

        var merchantUUID: String? {
            return merchants[seletectedMerchant].merchantUUID
        }
        
        var isLogout: Bool {
            return accountUUID == nil
        }
        
        func saveLoginData(password: String) {
            // Saves account
            print("ACCOUNT=\(account.debugDescription)")
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
            UserDefaults.standard.removeObject(forKey: WayAppPay.DefaultKey.ACCOUNT.rawValue)
            UserDefaults.standard.removeObject(forKey: WayAppPay.DefaultKey.EMAIL.rawValue)
            do {
                try Account.deletePassword(password, forEmail: email)
            } catch {
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }
    }

    static var session = Session()

}
