//
//  Merchant.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/1/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import UIKit

extension WayPay {
    
    struct Merchant: Codable, DefaultKeyPersistence, Identifiable, ContainerProtocol, Equatable, Hashable {

        // DefaultKeyPersistence
        var defaultKey: String {
            return WayPay.DefaultKey.MERCHANT.rawValue
        }
        
        static func ==(ls: Merchant, rs: Merchant) -> Bool {
            return ls.merchantUUID == rs.merchantUUID
        }

        static let defaultImageName = "questionmark.square"
        static let defaultName = "missing name"
        static let defaultLogo = "logoPlaceholder"
        static let minimumCommunityIDLength = 4

        enum Level: String, Codable {
            case ONE, TWO, THREE
        }
        
        enum Status: String, Codable {
           case CREATED, ENABLED, DISABLED
        }

        var merchantUUID: String
        var name: String?
        var description: String?
        var email: String?
        var address: Address?
        var website: String?
        var identityDocument: IdentityDocument?
        var logo: String?
        var creationDate: Date?
        var lastUpdateDate: Date?
        var currency: Currency?
        var level: Level?
        var communityID: String?
        var status: Status?

        
        init(name: String, email: String, level: Level = .ONE, communityID: String = OperationEnvironment.defaultCommunityID) {
            self.merchantUUID = ""
            self.name = name
            self.email = email
            self.level = level
            self.communityID = communityID
            self.currency = Currency.init(rawValue: Locale.current.currencyCode)
        }

        // Protocol Identifiable
        var id: String {
            return merchantUUID
        }
        
        var allowsPointCampaign: Bool {
            return (level == nil) || (level != Level.ONE)
        }

        var allowsGiftcard: Bool {
            return (level == nil) || (level != Level.ONE)
        }

        var isActive: Bool {
            return status == .ENABLED
        }
        
        func getPayerForTransaction(accountUUID: String, transactionUUID: String) {
        }
        
        static func createMerchant(merchant: Merchant, completion: @escaping ([Merchant]?, Error?) -> Void) {
            WayPay.API.createMerchant(merchant).fetch(type: [Merchant].self) { response in
                Logger.message("Merchant: createMerchant: response: \(response)")
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

        static func createMerchantForAccount(accountUUID: String, merchant: Merchant, logo: UIImage?, completion: @escaping ([Merchant]?, Error?) -> Void) {
            WayPay.API.createMerchantForAccount(accountUUID, merchant, logo).fetch(type: [Merchant].self) { response in
                Logger.message("Merchant: createMerchantForAccount: response: \(response)")
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

        static func createAccountAndMerchant(accountRequest: AccountRequest, merchant: Merchant, logo: UIImage?, completion: @escaping ([Merchant]?, Error?) -> Void) {
            WayPay.API.createAccountAndMerchant(accountRequest, merchant, logo).fetch(type: [Merchant].self) { response in
                Logger.message("Merchant: createAccountAndMerchant: response: \(response)")
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

        func sendPushNotification(pushNotification: PushNotification, completion: @escaping ([PushNotification]?, Error?) -> Void) {
            Logger.message("Sending pushNotification with text: \(pushNotification.text)")
            WayPay.API.sendPushNotificationForMerchant(merchantUUID, pushNotification).fetch(type: [PushNotification].self) { response in
                Logger.message("Merchant: sendPushNotification: responded: \(response)")
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


        func getTransactionsForAccount(_ accountUUID: String) {
            WayPay.API.getMerchantAccountTransactions(merchantUUID, accountUUID).fetch(type: [PaymentTransaction].self) { response in
                Logger.message("@@@@@@@@@@@@@@@@@@@@@@@@@ getTransactionsForAccount")
                if case .success(let response?) = response {
                    Logger.message("@@@@@@@@@@@@@@@@@@@@@@@@@ getTransactionsForAccount success")
                    if let transactions = response.result {
                        DispatchQueue.main.async {
                            WayPayApp.session.transactions.setToInOrder(transactions, by:
                                { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) })
                        }
                    } else {
                        Logger.message("@@@@@@@@@@@@@@@@@@@@@@@@@ getTransactionsForAccount EMPTY")
                        WayPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    Logger.message("@@@@@@@@@@@@@@@@@@@@@@@@@ getTransactionsForAccount failure")
                    Logger.message(error.localizedDescription)
                }
            }
        }

        func getTransactionDetailFor(accountUUID: String?, uuid: String) {
            guard let accountUUID = accountUUID else {
                Logger.message("missing accountUUID")
                return
            }
            WayPay.API.getTransaction(merchantUUID, accountUUID, uuid).fetch(type: [PaymentTransaction].self) { response in
                if case .success(let response?) = response {
                    if let transactions = response.result,
                        let transaction = transactions.first {
                        print("TRANSACTION DETAIL=\(transaction)")
                    } else {
                        WayPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    Logger.message(error.localizedDescription)
                }
            }
        }

        func getTransactionsForAccountForDay(_ accountUUID: String?, day: Date) {
            guard let accountUUID = accountUUID else {
                Logger.message("missing accountUUID")
                return
            }
            Logger.message("DATE: \(day), DAY: \(UI.reportDateFormatter.string(from: day))")
            WayPay.API.getMerchantAccountTransactionsForDay(merchantUUID, accountUUID, UI.reportDateFormatter.string(from: day)).fetch(type: [PaymentTransaction].self) { response in
                if case .success(let response?) = response {
                    if let transactions = response.result {
                        DispatchQueue.main.async {
                            WayPayApp.session.transactions.setToInOrder(transactions, by:
                                { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) })
                        }
                        print("TRANSACTIONS=\(transactions)")
                    } else {
                        WayPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    Logger.message(error.localizedDescription)
                }
            }
        }
        
        func getTransactionsForAccountByDates(accountUUID: String, initialDate: String?, finalDate: String?,
                                              completion: @escaping ([PaymentTransaction]?, Error?) -> Void) {
            if let initialDate = initialDate,
               let finalDate = finalDate {
                WayPay.API.getMerchantAccountTransactionsByDates(merchantUUID, accountUUID, initialDate, finalDate)
                    .fetch(type: [PaymentTransaction].self) { response in
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
        
        // STAGING
        // Las Rozas f157c0c5-49b4-445a-ad06-70727030b38a
        // WayApp Pay 1338193f-c6d9-4c19-a7d8-1c80fe9f017f
        // Super papeleria c35ce2ba-fb70-4d10-bd9b-d7407de77f97
        // PRODUCTION
        // WayApp Pay 3a825be4-c97c-4592-a61e-aa729d1fca74
        // La Rozas f157c0c5-49b4-445a-ad06-70727030b38a

        static func newSEPAS(initialDate: String, finalDate: String, completion: @escaping ([PaymentTransaction]?, Error?) -> Void) {
            WayPay.API.getSEPA(initialDate, finalDate,
                                  "issuerUUID", "3a825be4-c97c-4592-a61e-aa729d1fca74")
                .fetch(type: [PaymentTransaction].self) { response in
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

        func getDetailForAccount(_ accountUUID: String) {
            WayPay.API.getMerchantAccountDetail(merchantUUID, accountUUID).fetch(type: [Account].self) { response in
                if case .success(let response?) = response {
                    if let accounts = response.result,
                        let account = accounts.first {
                        Logger.message("Merchant=\(self.name ?? "no name")\nAccount=\(account.email ?? "no email")\n\(account)")
                    } else {
                        WayPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    Logger.message(error.localizedDescription)
                }
            }
        }

        static func getMerchantsForAccount(_ accountUUID: String, completion: @escaping ([Merchant]?, Error?) -> Void) {
            WayPay.API.getMerchants(accountUUID).fetch(type: [Merchant].self) { response in
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
        
        static func delete(_ merchantUUID: String) {
            WayPay.API.deleteMerchant(merchantUUID).fetch(type: [String].self) { response in
                if case .success(_) = response {
                    Logger.message("Merchant with UUID=\(merchantUUID) successfully deleted")
                } else if case .failure(let error) = response {
                    Logger.message(error.localizedDescription)
                }
            }
        }
    }
}
