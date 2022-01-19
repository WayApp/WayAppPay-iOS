//
//  UserPasswordSecurePersistance.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

extension WayPay {
    
    static func savePassword(_ password: String, forEmail email: String) throws {
        let genericPassword = WayAppUtils.KeychainHandler.GenericPasswordCredentials(account: email, password: password, service: WayPay.appName)
        let query = WayAppUtils.KeychainHandler.createGenericPasswordQuery(for: genericPassword)
        do {
            try WayAppUtils.KeychainHandler.addQuery(query)
        } catch WayAppUtils.KeychainHandler.Error.duplicateItem {
            try WayAppUtils.KeychainHandler.updateQuery(query, password: password)
        } catch {
            Logger.message(error.localizedDescription)
            throw error
        }
    }
    
    static func deletePassword(_ password: String, forEmail email: String) throws {
        let genericPassword = WayAppUtils.KeychainHandler.GenericPasswordCredentials(account: email, password: password, service: WayPay.appName)
        let query = WayAppUtils.KeychainHandler.createGenericPasswordQuery(for: genericPassword)
        do {
            try WayAppUtils.KeychainHandler.deleteQuery(query)
        } catch {
            throw error
        }
    }
    
    static func updatePassword(_ password: String, forEmail email: String) throws {
        let genericPassword = WayAppUtils.KeychainHandler.GenericPasswordCredentials(account: email, password: password, service: WayPay.appName)
        let query = WayAppUtils.KeychainHandler.createGenericPasswordQuery(for: genericPassword)
        do {
            try WayAppUtils.KeychainHandler.updateQuery(query, password: password)
        } catch {
            throw error
        }
    }
    
    static func retrievePassword(forEmail: String) -> String? {
        var password: String?
        do {
            password = try WayAppUtils.KeychainHandler.searchGenericPasswordQuery(account: forEmail, service: WayPay.appName)
        } catch {
            Logger.message(error.localizedDescription)
        }
        return password
    }
    
}

