//
//  Account.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

extension WayPay {

    struct AccountRequest: Codable {
        var user: String?
        var password: String?
        var firstName: String?
        var lastName: String?
        var phone: String?
        var timezone: String?
        var language: String?
        var currency: Currency?
        var countryCode: String?
        var countryName: String?
        
        init(firstName: String, lastName: String, password: String, phone: String, user: String) {
            self.firstName = firstName
            self.lastName = lastName
            self.password = password
            self.phone = phone
            self.user = user
        }
    }
        
}
