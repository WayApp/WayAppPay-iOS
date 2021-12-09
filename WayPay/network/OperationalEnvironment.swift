//
//  OperationalEnvironment.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

enum OperationalEnvironment {
    case production, staging
    
    static var current: OperationalEnvironment = .staging
    static var isSettingsSupportFunctionsActive = true
    
    static var wayappPayAPIBaseURL: String {
        switch OperationalEnvironment.current {
        case .production:
            return "https://pay.api.wayapp.com/pay/v1"
        case .staging:
            return "https://api.staging.wayapp.com/pay/v1"
        }
    }
    
    static var wayAppPayPublicKey: String {
        switch OperationalEnvironment.current  {
        case .production:
            return "776487e170a268e261d97e3c40d6e11545e18321"
        case .staging:
            return "8e261776487e170a545e2d97e3c4018321d6e116"
        }
    }

    static var alcazarPublicKey: String {
        return "2c7cae58-359c-4563-96cf-3f01b50313a6"
    }

    static var alcazarCustomerUUID: String {
        return "66ec43c2-b531-4a9d-971a-af8db2f481bd"
    }

    static var waypayProductionCustomerUUID: String {
        return "e94ef4c9-4b6e-44b9-bab8-1f8581c3f9f8"
    }

    static var alcazarPrivateKey: String {
        switch OperationalEnvironment.current  {
        case .production:
            return "6eead822-8645-4af8-b56b-21aba9d39458"
        case .staging:
            return "614a932c-4d0e-11ec-81d3-0242ac150014"
        }
    }


    static var wayAppPayPrivateKey: String {
        switch OperationalEnvironment.current  {
        case .production:
            return "41f5681ec660748e9832177993fd7c9fe763458e"
        case .staging:
            return "748e93458e818fe76e3fd7c9741f5699c6603217"
        }
    }

    static var walletAPIBaseURL: String {
        switch OperationalEnvironment.current {
        case .production:
            return "https://api.wayapp.com/wallet/v1"
        case .staging:
            return "https://api.wayapp.com/wallet/v1"
        }
    }

    static var walletPublicKey: String {
        switch OperationalEnvironment.current  {
        case .production:
            return "ed97b9fa56b248ba8fa8c1df245bc332f7657593"
        case .staging:
            return "ed97b9fa56b248ba8fa8c1df245bc332f7657593"
        }
    }


    static var walletPrivateKey: String {
        switch OperationalEnvironment.current  {
        case .production:
            return "be5d8786bcc34c55933869df022f0d0ca9c3f30a"
        case .staging:
            return "be5d8786bcc34c55933869df022f0d0ca9c3f30a"
        }
    }
    
    // AfterBanks
    static var afterBanksConsentCallback = "https://api.staging.wayapp.com/pay/v1/afterbanks/consentCallback"
    static var afterBanksPaymentCallback = "https://api.staging.wayapp.com/pay/v1/afterbanks/paymentCallback"

    static var afterBanksBaseURL: String {
        switch OperationalEnvironment.current  {
        case .production:
            return "https://apipsd2.afterbanks.com"
        case .staging:
            return "https://apipsd2.afterbanks.com"
        }
    }
    
    static var afterBanksServiceKey: String {
        switch OperationalEnvironment.current  {
        case .production:
            return "x7zm3tzvemfecakd"
        case .staging:
            return "s2be1zyaihpmhgzy"
        }
    }

    static var receiptValidationURL: String {
        switch OperationalEnvironment.current  {
        case .production:
            return "https://buy.itunes.apple.com/verifyReceipt"
        case .staging:
            return "https://sandbox.itunes.apple.com/verifyReceipt"
        }
    }
    
    static var inPurchaseSharedKey: String {
        return "376642c3165444a2950632ea6f7c52ea"
    }

    static var afterBanksToken: String {
        return "sandbox.8wdg03rh"
    }
    
    static var afterBanksIBANs: [String] {
        return["ES8401826450000201500191", "ES1801822200120201933578", "ES2501822200160201933547", "ES4901822200110201933554", "ES7301826208302012068108"]
    }
    
    static var defaultCommunityID: String {
        switch OperationalEnvironment.current  {
        case .production:
            return "3a825be4-c97c-4592-a61e-aa729d1fca74"
        case .staging:
            return "f01ffb3f-5b16-4238-abf0-215c2c2c4c74"
        }
    }

}
