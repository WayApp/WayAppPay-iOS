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
            case CREATED // registered but not validated
            case ACTIVE // email validated
            case INACTIVE // blocked by Admin
        }
        
        var accountUUID: String
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
        
        static func load(email: String, password: String) {
            WayAppPay.API.getAccount(email, password).fetch(type: [WayAppPay.Account].self) { response in
                if case .success(let response?) = response {
                    if let accounts = response.result,
                        let account = accounts.first {
                        Session.account = account
                    } else {
                        WayAppPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }
        
    }
}

extension WayAppPay {
    
    enum Currency: String, Codable {
        case USD
        case EUR
    }

    struct Address: Codable {
        var line1: String?
        var city: String?
        var stateProvince: String?
        var country: String?
        var postalCode: String?
        var formatted: String {
            if let line1 = line1,
                let city = city {
                return "\(line1) \(postalCode ?? "") \(city), \(stateProvince ?? "")"
            } else {
                return "-"
            }
        }
    }

}

