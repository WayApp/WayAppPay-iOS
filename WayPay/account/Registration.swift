//
//  Account.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

extension WayPay {

    struct Registration: Codable {
        
        var firstName: String?
        var lastName: String?
        var email: String?
        var balance: Int?
        var issuerUUID: String?
        var issuerCode: String?
        var currency: Currency?
        var timezone: String?
        var language: String?
        var creationDate: Date?
        var lastUpdateDate: Date?
        
        init(email: String, issuerUUID: String, balance: Int = 0) {
            self.email = email
            self.issuerUUID = issuerUUID
            self.balance = balance
        }
    }
}
