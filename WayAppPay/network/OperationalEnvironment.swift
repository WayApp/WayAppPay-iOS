//
//  OperationalEnvironment.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

var environment: Environment = Environment.production

enum Environment {
    case production, staging
    
    var wayappPayAPIBaseURL: String {
        switch self {
        case .production:
            return "https://api.staging.wayapp.com/pay/v1"
        case .staging:
            return ""
        }
    }
        
    var wayAppPayPublicKey: String {
        switch self {
        case .production:
            return "8e261776487e170a545e2d97e3c4018321d6e116"
        case .staging:
            return "8e261776487e170a545e2d97e3c4018321d6e116"
        }
    }

    var wayAppPayPrivateKey: String {
        switch self {
        case .production:
            return "748e93458e818fe76e3fd7c9741f5699c6603217"
        case .staging:
            return "748e93458e818fe76e3fd7c9741f5699c6603217"
        }
    }

    var deepLinkBaseURL: String {
        switch self {
        case .production:
            return "https://api.abanca.com/e/alavuelta/wc/links?deeplink="
        case .staging:
            return ""
        }
    }
}

