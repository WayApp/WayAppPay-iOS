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
        case REMEMBER_EMAIL // Stores the email for biometrics login
        case EMAIL // Stores the email for biometrics login
        // Session related
        case ACCOUNT // Stores the user account while in session
        
        static func resetSessionKeys() {
            // Only session keys
            UserDefaults.standard.removeObject(forKey: WayAppPay.DefaultKey.EMAIL.rawValue)
            UserDefaults.standard.removeObject(forKey: WayAppPay.DefaultKey.ACCOUNT.rawValue)
            UserDefaults.standard.synchronize()
        }
        
        static func logout() {
            resetSessionKeys()
        }
    }
}
