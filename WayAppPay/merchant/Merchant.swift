//
//  Merchant.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/1/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    
    struct Merchant: Codable, Identifiable, ContainerProtocol, Equatable, Hashable {
        
        static func ==(ls: Merchant, rs: Merchant) -> Bool {
            return ls.merchantUUID == rs.merchantUUID
        }

        static let defaultImageName = "questionmark.square"
        static let defaultName = "missing name"

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
        
        init(name: String) {
            self.merchantUUID = UUID().uuidString
            self.name = name
            self.description = name
        }

        // Protocol Identifiable
        var id: String {
            return merchantUUID
        }

        func getPayerForTransaction(accountUUID: String, transactionUUID: String) {
            
        }

        func getTransactionsForAccount(_ accountUUID: String) {
            WayAppPay.API.getMerchantAccountTransactions(merchantUUID, accountUUID).fetch(type: [PaymentTransaction].self) { response in
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
                        WayAppPay.API.reportError(response)
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
            WayAppPay.API.getTransaction(merchantUUID, accountUUID, uuid).fetch(type: [PaymentTransaction].self) { response in
                if case .success(let response?) = response {
                    if let transactions = response.result,
                        let transaction = transactions.first {
                        print("TRANSACTION DETAIL=\(transaction)")
                    } else {
                        WayAppPay.API.reportError(response)
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
            WayAppUtils.Log.message("DATE: \(day), DAY: \(WayAppPay.reportDateFormatter.string(from: day))")
            WayAppPay.API.getMerchantAccountTransactionsForDay(merchantUUID, accountUUID, WayAppPay.reportDateFormatter.string(from: day)).fetch(type: [PaymentTransaction].self) { response in
                if case .success(let response?) = response {
                    if let transactions = response.result {
                        DispatchQueue.main.async {
                            session.transactions.setToInOrder(transactions, by:
                                { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) })
                        }
                        print("TRANSACTIONS=\(transactions)")
                    } else {
                        WayAppPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }
        
        func getTransactionsForAccountByDates(accountUUID: String, initialDate: Date, finalDate: Date,
                                              completion: @escaping ([PaymentTransaction]?, Error?) -> Void) {
            WayAppPay.API.getMerchantAccountTransactionsByDates(merchantUUID, accountUUID, WayAppPay.reportDateFormatter.string(from: initialDate), WayAppPay.reportDateFormatter.string(from: finalDate))
                .fetch(type: [PaymentTransaction].self) { response in
                    switch response {
                    case .success(let response?):
                        completion(response.result, nil)
                    case .failure(let error):
                        completion(nil, error)
                    default:
                        completion(nil, WayAppPay.API.ResponseError.INVALID_SERVER_DATA)
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
            WayAppPay.API.getSEPA(initialDate, finalDate,
                                  "issuerUUID", "3a825be4-c97c-4592-a61e-aa729d1fca74")
                .fetch(type: [PaymentTransaction].self) { response in
                    switch response {
                    case .success(let response?):
                        completion(response.result, nil)
                    case .failure(let error):
                        completion(nil, error)
                    default:
                        completion(nil, WayAppPay.API.ResponseError.INVALID_SERVER_DATA)
                    }
            }
        }

        func getReportID(for accountUUID: String?, month: String) {
            guard let accountUUID = accountUUID else {
                WayAppUtils.Log.message("missing accountUUID")
                return
            }
            WayAppUtils.Log.message("accountUUID: \(accountUUID), month: \(month)")
            WayAppPay.API.getMonthReportID(merchantUUID, accountUUID, month).fetch(type: [ReportID].self) { response in
                if case .success(let response?) = response {
                    if let reportIDs = response.result,
                        let reportID = reportIDs.first {
                        DispatchQueue.main.async {
                            session.thisMonthReportID = reportID
                        }
                        WayAppUtils.Log.message("ReportID=\(reportID)")
                    } else {
                        WayAppPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }

        func getDetailForAccount(_ accountUUID: String) {
            WayAppPay.API.getMerchantAccountDetail(merchantUUID, accountUUID).fetch(type: [Account].self) { response in
                if case .success(let response?) = response {
                    if let accounts = response.result,
                        let account = accounts.first {
                        WayAppUtils.Log.message("Merchant=\(self.name ?? "no name")\nAccount=\(account.email ?? "no email")\n\(account)")
                    } else {
                        WayAppPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }

        static func getMerchantsForAccount(_ accountUUID: String, completion: @escaping ([Merchant]?, Error?) -> Void) {
            WayAppPay.API.getMerchants(accountUUID).fetch(type: [Merchant].self) { response in
                switch response {
                case .success(let response?):
                    completion(response.result, nil)
                case .failure(let error):
                    completion(nil, error)
                default:
                    completion(nil, WayAppPay.API.ResponseError.INVALID_SERVER_DATA)
                }
            }
        }
        
        static func delete(_ merchantUUID: String) {
            WayAppPay.API.deleteMerchant(merchantUUID).fetch(type: [String].self) { response in
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
