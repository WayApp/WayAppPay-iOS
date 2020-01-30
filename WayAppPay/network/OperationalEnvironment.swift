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
    case development, production, staging
    
    var onboardingMoreInfoURL: String {
        return "https://alavuelta.abanca.com"
    }
    
    var onlineStoreBaseURL: String {
        return "https://miscompras.alavuelta.com/#/merchants/"
    }
    
    var profileMoreInfoURL: String {
        return "https://www.abanca.com/es/empresas/otros-servicios/alavuelta/"
    }
    
    var helpURL: String {
        return "https://alavuelta.com/faqs/"
    }
    
    var alavueltaAPIBaseURL: String {
        switch self {
        case .development:
            return "https://api.abanca.com/d/alavuelta"
        case .production:
            return "https://api.abanca.com/e/alavuelta"
        case .staging:
            return "https://alavuelta.api.wayapp.com/alavuelta/v1"
        }
    }
    
    var abancaOauthBaseURL: String {
        switch self {
        case .development:
            return "https://api.abanca.com/d/oauth2/token"
        case .production:
            return "https://api.abanca.com/e/oauth2/token"
        case .staging:
            return "https://alavuelta.api.wayapp.com/alavuelta/v1/oauth2/token"
        }
    }
    
    var abancaFederatedOauthBaseURL: String {
        switch self {
        case .development:
            return "https://bancaelectronica.abanca.com/WELE200M_Auth_ini.aspx?"
        case .production:
            return "https://bancaelectronica.abanca.com/WELE200M_Auth_ini.aspx?"
        case .staging:
            return ""
        }
    }
    
    var abancaOauthAuthKey: String {
        switch self {
        case .development:
            return "ecbe18ad-7ba7-4259-8f53-38e78212623d"
        case .production:
            return "ecd57a3c-382d-4184-bea0-1fd6a74a56d4"
        case .staging:
            return "9ba9b50b-7321-4592-9a05-1bf59ee8cb9f"
        }
    }
    
    var abancaOauthAPIKey: String {
        return "CF73B7AD-1A77-4958-B651-D5980315C284"
    }

    var deepLinkBaseURL: String {
        switch self {
        case .development:
            return "https://api.abanca.com/d/alavuelta/wc/links?deeplink="
        case .production:
            return "https://api.abanca.com/e/alavuelta/wc/links?deeplink="
        case .staging:
            return ""
        }
    }
    
    var application: String {
        return "TWENCR0001"
    }
    
    var emmaKey: String {
        switch self {
        case .development:
            return "alavueltawA6R8BkZy8"
        case .production:
            return "alavueltaRbV7JKtpo"
        case .staging:
            return "alavueltawA6R8BkZy8"
        }
    }
}

