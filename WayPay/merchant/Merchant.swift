//
//  Merchant.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/1/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import UIKit

extension WayPay {
    
    struct Merchant: Codable, Identifiable, ContainerProtocol, Equatable, Hashable {
        
        static func ==(ls: Merchant, rs: Merchant) -> Bool {
            return ls.merchantUUID == rs.merchantUUID
        }

        static let defaultImageName = "questionmark.square"
        static let defaultName = "missing name"
        static let defaultLogo = "logoPlaceholder"

        enum Level: String, Codable {
            case ONE, TWO, THREE
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
        
        init(name: String, email: String, level: Level = .ONE) {
            self.merchantUUID = ""
            self.name = name
            self.email = email
            self.level = level
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

        func getPayerForTransaction(accountUUID: String, transactionUUID: String) {
        }
        
        static func createMerchant(merchant: Merchant, completion: @escaping ([Merchant]?, Error?) -> Void) {
            WayPay.API.createMerchant(merchant).fetch(type: [Merchant].self) { response in
                WayAppUtils.Log.message("Merchant: createMerchant: response: \(response)")
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
                WayAppUtils.Log.message("Merchant: createMerchantForAccount: response: \(response)")
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
                WayAppUtils.Log.message("@@@@@@@@@@@@@@@@@@@@@@@@@ getTransactionsForAccount")
                if case .success(let response?) = response {
                    WayAppUtils.Log.message("@@@@@@@@@@@@@@@@@@@@@@@@@ getTransactionsForAccount success")
                    if let transactions = response.result {
                        DispatchQueue.main.async {
                            session.transactions.setToInOrder(transactions, by:
                                { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) })
                        }
                    } else {
                        WayAppUtils.Log.message("@@@@@@@@@@@@@@@@@@@@@@@@@ getTransactionsForAccount EMPTY")
                        WayPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message("@@@@@@@@@@@@@@@@@@@@@@@@@ getTransactionsForAccount failure")
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }

        func getTransactionDetailFor(accountUUID: String?, uuid: String) {
            guard let accountUUID = accountUUID else {
                WayAppUtils.Log.message("missing accountUUID")
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
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }

        func getTransactionsForAccountForDay(_ accountUUID: String?, day: Date) {
            guard let accountUUID = accountUUID else {
                WayAppUtils.Log.message("missing accountUUID")
                return
            }
            WayAppUtils.Log.message("DATE: \(day), DAY: \(WayPay.reportDateFormatter.string(from: day))")
            WayPay.API.getMerchantAccountTransactionsForDay(merchantUUID, accountUUID, WayPay.reportDateFormatter.string(from: day)).fetch(type: [PaymentTransaction].self) { response in
                if case .success(let response?) = response {
                    if let transactions = response.result {
                        DispatchQueue.main.async {
                            session.transactions.setToInOrder(transactions, by:
                                { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) })
                        }
                        print("TRANSACTIONS=\(transactions)")
                    } else {
                        WayPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
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

        func getReportID(for accountUUID: String?, month: String) {
            guard let accountUUID = accountUUID else {
                WayAppUtils.Log.message("missing accountUUID")
                return
            }
            WayAppUtils.Log.message("accountUUID: \(accountUUID), month: \(month)")
            WayPay.API.getMonthReportID(merchantUUID, accountUUID, month).fetch(type: [ReportID].self) { response in
                if case .success(let response?) = response {
                    if let reportIDs = response.result,
                        let reportID = reportIDs.first {
                        DispatchQueue.main.async {
                            session.thisMonthReportID = reportID
                        }
                        WayAppUtils.Log.message("ReportID=\(reportID)")
                    } else {
                        WayPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }

        func getDetailForAccount(_ accountUUID: String) {
            WayPay.API.getMerchantAccountDetail(merchantUUID, accountUUID).fetch(type: [Account].self) { response in
                if case .success(let response?) = response {
                    if let accounts = response.result,
                        let account = accounts.first {
                        WayAppUtils.Log.message("Merchant=\(self.name ?? "no name")\nAccount=\(account.email ?? "no email")\n\(account)")
                    } else {
                        WayPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
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
                    WayAppUtils.Log.message("Merchant with UUID=\(merchantUUID) successfully deleted")
                    DispatchQueue.main.async {
                        if let merchant = session.merchants[merchantUUID] {
                            session.merchants.remove(merchant)
                        }
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }
    }
}
