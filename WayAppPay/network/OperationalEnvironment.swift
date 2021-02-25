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
    
    static var current: OperationalEnvironment = .production
    
    static var wayappPayAPIBaseURL: String {
        switch OperationalEnvironment.current {
        case .production:
            return "https://pay.api.wayapp.com/pay/v1"
        case .staging:
            return "https://api.staging.wayapp.com/pay/v1"
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

    static var wayAppPayPublicKey: String {
        switch OperationalEnvironment.current  {
        case .production:
            return "776487e170a268e261d97e3c40d6e11545e18321"
        case .staging:
            return "8e261776487e170a545e2d97e3c4018321d6e116"
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

    static var wayAppPayPrivateKey: String {
        switch OperationalEnvironment.current  {
        case .production:
            return "41f5681ec660748e9832177993fd7c9fe763458e"
        case .staging:
            return "748e93458e818fe76e3fd7c9741f5699c6603217"
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

    static var afterBanksToken: String {
        return "sandbox.8wdg03rh"
    }
    
    static var afterBanksIBANs: [String] {
        return["ES8401826450000201500191", "ES1801822200120201933578", "ES2501822200160201933547", "ES4901822200110201933554", "ES7301826208302012068108"]
    }
}
