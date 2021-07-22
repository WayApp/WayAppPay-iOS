//
//  Account.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

extension WayPay {

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
            return WayPay.DefaultKey.ACCOUNT.rawValue
        }
        
        var id: String {
            return accountUUID
        }
        
        static func hashedPIN(_ pin: String) -> String {
            let escapedPIN = pin.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
            return escapedPIN.sha1()
        }

        static func savePassword(_ password: String, forEmail email: String) throws {
            let genericPassword = KeychainHandler.GenericPasswordCredentials(account: email, password: password, service: WayPay.appName)
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
            let genericPassword = KeychainHandler.GenericPasswordCredentials(account: email, password: password, service: WayPay.appName)
            let query = KeychainHandler.createGenericPasswordQuery(for: genericPassword)
            do {
                try KeychainHandler.deleteQuery(query)
            } catch {
                throw error
            }
        }
        
        static func updatePassword(_ password: String, forEmail email: String) throws {
            let genericPassword = KeychainHandler.GenericPasswordCredentials(account: email, password: password, service: WayPay.appName)
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
                password = try KeychainHandler.searchGenericPasswordQuery(account: forEmail, service: WayPay.appName)
            } catch {
                WayAppUtils.Log.message(error.localizedDescription)
            }
            return password
        }

        static func register(registration: Registration) {
            WayPay.API.registrationAccount(registration).fetch(type: [Registration].self) { response in
                WayAppUtils.Log.message("Account: registerAccount: response: \(response)")
                if case .success(let response?) = response {
                    if let registrations = response.result,
                        let registration = registrations.first {
                        print("success success success success success: \(registration)")
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }

        static func changePIN(_ email: String, newPIN: String, completion: @escaping ([Account]?, Error?) -> Void) {
            WayPay.API.changePIN(ChangePIN(email: email, oldPin: "", newPin: Account.hashedPIN(newPIN))).fetch(type: [Account].self) { response in
                switch response {
                case .success(let response?):
                    completion(response.result, nil)
                case .failure(let error):
                    completion(nil, error)
                default:
                    completion(nil, WayPay.API.ResponseError.INVALID_SERVER_DATA)
                }
            }
        }
        
        static func forgotPIN(_ email: String, completion: @escaping ([OTP]?, Error?) -> Void) {
            WayPay.API.forgotPIN(ChangePIN(email: email, oldPin: "", newPin: "")).fetch(type: [OTP].self) { response in
                switch response {
                case .success(let response?):
                    completion(response.result, nil)
                case .failure(let error):
                    completion(nil, error)
                default:
                    completion(nil, WayPay.API.ResponseError.INVALID_SERVER_DATA)
                }
            }
        }

        static func load(email: String, pin: String, completion: @escaping ([Account]?, Error?) -> Void) {
            WayPay.API.getAccount(email, Account.hashedPIN(pin)).fetch(type: [WayPay.Account].self) { response in
                switch response {
                case .success(let response?):
                    completion(response.result, nil)
                case .failure(let error):
                    completion(nil, error)
                default:
                    completion(nil, WayPay.API.ResponseError.INVALID_SERVER_DATA)
                }
            }
        } // load
            
        static func delete(_ accountUUID: String) {
            WayPay.API.deleteAccount(accountUUID).fetch(type: [String].self) { response in
                WayAppUtils.Log.message("DELETE Response")
                if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                } else if case .success(let response?) = response {
                    WayAppUtils.Log.message("DELETE Response: \(response.debugOutput())")

                    if response.code == 204 {
                        WayAppUtils.Log.message("Account: \(accountUUID). DELETED.")
                    } else {
                        WayAppUtils.Log.message("Response: \(response.debugOutput())")
                    }
                }
            }
        }
        
        static func getRewards(_ transaction: PaymentTransaction, completion: @escaping ([Reward]?, Error?) -> Void) {
            WayPay.API.getRewards(transaction).fetch(type: [Reward].self) { response in
                switch response {
                case .success(let response?):
                    completion(response.result, nil)
                case .failure(let error):
                    completion(nil, error)
                default:
                    completion(nil, WayPay.API.ResponseError.INVALID_SERVER_DATA)
                }
            }
        }
        
        static func checkin(_ transaction: PaymentTransaction, completion: @escaping ([WayPay.Checkin]?, Error?) -> Void) {
            WayPay.API.checkin(transaction).fetch(type: [WayPay.Checkin].self) { response in
                switch response {
                case .success(let response?):
                    completion(response.result, nil)
                case .failure(let error):
                    completion(nil, error)
                default:
                    completion(nil, WayPay.API.ResponseError.INVALID_SERVER_DATA)
                }
            }
        }

    }
}

extension WayPay {
    
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

