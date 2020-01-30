//
//  Session.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import UIKit

extension WayAppPay {
    
        struct Session {
            static let downloadGroup = DispatchGroup()
            
            private init() { }
            // Data

            // MARK: - Account
            static var account = WayAppPay.Account()
            
            
            static var accountUUID: String {
                if account.accountUUID == nil {
                    fatalError("Missing accountUUID")
                }
                return account.accountUUID!
            }
            
            static var userAvatar: UIImage?
    }

}
