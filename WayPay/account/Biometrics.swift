//
//  Biometrics.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

extension WayPay {

//    static func saveBiometricsEmail(_ email: String) {
//        UserDefaults.standard.set(email, forKey: WayAppPay.DefaultKey.EMAIL.rawValue)
//        UserDefaults.standard.synchronize()
//    }
//
//    static func deleteBiometricsEmail() {
//        UserDefaults.standard.removeObject(forKey: WayAppPay.DefaultKey.EMAIL.rawValue)
//        UserDefaults.standard.synchronize()
//    }
//
//    static func retrieveBiometricsEmail() -> String? {
//        return UserDefaults.standard.string(forKey: WayAppPay.DefaultKey.EMAIL.rawValue)
//    }
//
//    static func disableBiometrics() {
//        UserDefaults.standard.set(true, forKey: WayAppPay.DefaultKey.IS_BIOMETRICS_DISABLED.rawValue)
//        if let email = retrieveBiometricsEmail(),
//            let password = retrievePassword(forEmail: email) {
//            do {
//                try deletePassword(password, forEmail: email)
//            } catch {
//                WayAppUtils.Log.message(error.localizedDescription)
//            }
//        }
//        deleteBiometricsEmail()
//    }
//
//    static func enableBiometrics(email: String) {
//        saveBiometricsEmail(email)
//        UserDefaults.standard.set(false, forKey: WayAppPay.DefaultKey.IS_BIOMETRICS_DISABLED.rawValue)
//        UserDefaults.standard.synchronize()
//    }
//
//    static func isBiometricsDisabled() -> Bool {
//        return UserDefaults.standard.bool(forKey: WayAppPay.DefaultKey.IS_BIOMETRICS_DISABLED.rawValue)
//    }
//
//    static func biometricsData() -> (String, String)? {
//        if let email = retrieveBiometricsEmail(),
//            let password = retrievePassword(forEmail: email),
//            !UserDefaults.standard.bool(forKey: WayAppPay.DefaultKey.IS_BIOMETRICS_DISABLED.rawValue) {
//            return (email, password)
//        }
//        return nil
//    }

}
