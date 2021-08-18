//
//  DefaultKeys.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

extension WayPay {
    public enum DefaultKey: String {
        // Not session related
        case EMAIL // Stores the email for biometrics login
        // Session related
        case ACCOUNT // Stores the user account while in session
        case MERCHANT // Stores selected merchant
        case SKIP_ONBOARDING // Does not reset with logout

        static func resetSessionKeys() {
            // Only session keys
            UserDefaults.standard.removeObject(forKey: WayPay.DefaultKey.EMAIL.rawValue)
            UserDefaults.standard.removeObject(forKey: WayPay.DefaultKey.ACCOUNT.rawValue)
            UserDefaults.standard.removeObject(forKey: WayPay.DefaultKey.MERCHANT.rawValue)
            UserDefaults.standard.synchronize()
        }
        
        static func logout() {
            resetSessionKeys()
        }
    }
}
