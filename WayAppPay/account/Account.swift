//
//  Account.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {

    struct ChangePIN: Codable {
        var email: String
        var oldPin: String
        var newPin: String
    }
    
    struct OTP: Codable {
        var email: String
        var otp: String
        var timeExpiration: Int
        var timeRequest: Int
        var creationDate: Date
    }

    struct Account: Codable, DefaultKeyPersistence, ContainerProtocol {
        
        static let PINLength = 4
        static let phoneNumberMinLength = 9
        static let phoneNumberMaxLength = 9
                
        enum Status: String, Codable {
            case CREATED // registered but not validated
            case ACTIVE // email validated
            case INACTIVE // blocked by Admin
        }
        
        var accountUUID: String
        var status: Status?
        var firstName: String?
        var lastName: String?
        var document: IdentityDocument?
        var phone: String?
        var email: String?
        var photo: String?
        var timezone: String?
        var language: String?
        var currency: Currency?
        var countryCode: String?
        var countryName: String?
        var address: Address?
        var creationDate: Date?
        var lastUpdateDate: Date?
        
        // DefaultKeyPersistence
        var defaultKey: String {
            return WayAppPay.DefaultKey.ACCOUNT.rawValue
        }
        
        var containerID: String {
            return accountUUID
        }
        
        static func hashedPIN(_ pin: String) -> String {
            let escapedPIN = pin.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
            return escapedPIN.sha1()
        }

        static func savePassword(_ password: String, forEmail email: String) throws {
            let genericPassword = KeychainHandler.GenericPasswordCredentials(account: email, password: password, service: WayAppPay.appName)
            let query = KeychainHandler.createGenericPasswordQuery(for: genericPassword)
            do {
                try KeychainHandler.addQuery(query)
            } catch KeychainHandler.Error.duplicateItem {
                try KeychainHandler.updateQuery(query, password: password)
            } catch {
                WayAppUtils.Log.message(error.localizedDescription)
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
                WayAppUtils.Log.message(error.localizedDescription)
            }
            return password
        }

        static func changePINforEmail(_ email: String, currentPIN: String, newPIN: String, completion: @escaping (Error?) -> Void) {
            WayAppPay.API.changePIN(ChangePIN(email: email, oldPin: Account.hashedPIN(currentPIN), newPin: Account.hashedPIN(newPIN))).fetch(type: [Account].self) { response in
                WayAppUtils.Log.message("RESPONSE: \(response)")
                if case .success(let response?) = response {
                    if let accounts = response.result,
                        let account = accounts.first {
                        completion(nil)
                        print("success success success success success: \(account)")
                    }
                } else if case .failure(let error) = response {
                    completion(error)
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }
        
        static func forgotPINforEMAIL(_ email: String, completion: @escaping (String?, Error?) -> Void) {
            WayAppPay.API.forgotPIN(ChangePIN(email: email, oldPin: "", newPin: "")).fetch(type: [OTP].self) { response in
                WayAppUtils.Log.message("RESPONSE: \(response)")
                if case .success(let response?) = response {
                    if let otps = response.result,
                        let otp = otps.first {
                        completion(otp.otp, nil)
                        print("OTP success success success success success: \(otp)")
                    }
                } else if case .failure(let error) = response {
                    completion(nil, error)
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }

        static func load(email: String, pin: String) {
            WayAppUtils.Log.message("**************HASHED 1234 ===\(Account.hashedPIN(pin))")
            WayAppPay.API.getAccount(email, Account.hashedPIN(pin)).fetch(type: [WayAppPay.Account].self) { response in
                if case .success(let response?) = response {
                    if let accounts = response.result,
                        let account = accounts.first {
                        DispatchQueue.main.async {
                            session.account = account
                            session.saveLoginData(pin: pin)
                        }
                    } else {
                        DispatchQueue.main.async {
                            session.loginError = true
                        }
                        WayAppPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        } // load
                
    }
}

extension WayAppPay {
    
    enum Currency: String, Codable {
        case CHF, CLP, COP, EUR, GBP, USD, VEF, Unknown
    }

    struct Address: Codable, Hashable {
        var line1: String?
        var city: String?
        var stateProvince: String?
        var country: String?
        var postalCode: String?
        var formatted: String {
            if let line1 = line1,
                let city = city {
                return "\(line1) \(postalCode ?? "") \(city), \(stateProvince ?? "")"
            } else {
                return "-"
            }
        }
        
        static func ==(ls: Address, rs: Address) -> Bool {
            return (ls.formatted == rs.formatted)
        }

    }

}

