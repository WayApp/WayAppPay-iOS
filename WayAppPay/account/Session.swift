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
    
    struct Session {
            
        private init() { }
        
        final class AccountData: ObservableObject {
            @Published var merchants = Container<Merchant>()
            @Published var products = Container<Product>()
        }

        static var accountData = AccountData()
        
        static var account: Account? {
            didSet {
                if let account = account {
                    Merchant.loadMerchantsForAccount(account.accountUUID)
                }
            }
        }
        
        static var accountUUID: String? {
            return account?.accountUUID
        }

        static var merchantUUID: String? {
            didSet {
                if let merchantUUID = merchantUUID {
                    Product.loadForMerchant(merchantUUID)
                }
            }
        }
        
    }

}
