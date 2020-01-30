//
//  Account.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {

    struct Account: Codable, DefaultKeyPersistence {
        
        static let PINLength = 4
        static let phoneNumberMinLength = 9
        static let phoneNumberMaxLength = 9
        
        enum Status: String, Codable {
            case REGISTERED // registered but not validated
            case ACTIVE // email validated
            case INACTIVE // blocked by Admin
        }
        
        var accountUUID: String?
        var status: Status?
        var firstName: String?
        var lastName: String?
        var document: IdentityDocument?
        var phone: String?
        var email: String?
        var photo: String?
        var timezone: String?
        var language: String?
        var currency: Currency?
        var countryCode: String?
        var countryName: String?
        var address: Address?
        var creationDate: Date?
        var lastUpdateDate: Date?
        
        // DefaultKeyPersistence
        var defaultKey: String {
            return WayAppPay.DefaultKey.ACCOUNT.rawValue
        }
        
        init() {
        }
    }

}
