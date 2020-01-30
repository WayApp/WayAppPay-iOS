//
//  UserPasswordSecurePersistance.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    
    static func savePassword(_ password: String, forEmail email: String) throws {
        let genericPassword = KeychainHandler.GenericPasswordCredentials(account: email, password: password, service: WayAppPay.appName)
        let query = KeychainHandler.createGenericPasswordQuery(for: genericPassword)
        do {
            try KeychainHandler.addQuery(query)
        } catch KeychainHandler.Error.duplicateItem {
            try KeychainHandler.updateQuery(query, password: password)
        } catch {
            Log.message(error.localizedDescription)
            throw error
        }
    }
    
    static func deletePassword(_ password: String, forEmail email: String) throws {
        let genericPassword = KeychainHandler.GenericPasswordCredentials(account: email, password: password, service: WayAppPay.appName)
        let query = KeychainHandler.createGenericPasswordQuery(for: genericPassword)
        do {
            try KeychainHandler.deleteQuery(query)
        } catch {
            throw error
        }
    }
    
    static func updatePassword(_ password: String, forEmail email: String) throws {
        let genericPassword = KeychainHandler.GenericPasswordCredentials(account: email, password: password, service: WayAppPay.appName)
        let query = KeychainHandler.createGenericPasswordQuery(for: genericPassword)
        do {
            try KeychainHandler.updateQuery(query, password: password)
        } catch {
            throw error
        }
    }
    
    static func retrievePassword(forEmail: String) -> String? {
        var password: String?
        do {
            password = try KeychainHandler.searchGenericPasswordQuery(account: forEmail, service: WayAppPay.appName)
        } catch {
            Log.message(error.localizedDescription)
        }
        return password
    }
    
}

