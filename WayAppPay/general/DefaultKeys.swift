//
//  DefaultKeys.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    public enum DefaultKey: String {
        // Not session related
        case ONBOARDING_SHOWN // saved when onboarding is shown the first time
        case APP_LAUNCHES // counter
        case IS_BIOMETRICS_DISABLED // Stores preference, FALSE by default
        case EMAIL // Stores the email for biometrics login
        // Session related
        case ACCOUNT // Stores the user account while in session
        case TOKEN // Stores the user token while in session
        case TERMS_ACCEPTED // saved when user accepts terms and conditions
        case PUSH_NOTIFICATION_PROMPT // configuration option
        case LOCALIZATION_PROMPT // configuration option
        
        static func resetSessionKeys() {
            // Only session keys
            UserDefaults.standard.removeObject(forKey: WayAppPay.DefaultKey.ACCOUNT.rawValue)
            UserDefaults.standard.removeObject(forKey: WayAppPay.DefaultKey.TOKEN.rawValue)
            UserDefaults.standard.removeObject(forKey: WayAppPay.DefaultKey.TERMS_ACCEPTED.rawValue)
            UserDefaults.standard.removeObject(forKey: WayAppPay.DefaultKey.LOCALIZATION_PROMPT.rawValue)
            UserDefaults.standard.removeObject(forKey: WayAppPay.DefaultKey.PUSH_NOTIFICATION_PROMPT.rawValue)
            UserDefaults.standard.synchronize()
        }
        
        static func logout() {
            resetSessionKeys()
        }
    }

}
