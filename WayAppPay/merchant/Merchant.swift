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

        var containerID: String {
            return merchantUUID
        }

        func getAccounts() {
//            session.account!.changePIN(currentPIN: "4321", newPIN: "1234")
//            session.account!.forgotPIN()
            
            
            WayAppPay.API.getMerchantAccounts(merchantUUID).fetch(type: [Account].self) { response in
                if case .success(let response?) = response {
                    if let accounts = response.result {
                        DispatchQueue.main.async {
                            session.accounts.setTo(accounts)
                        }
                        // Francesita "199c742b-4f85-4d1e-a949-785701bdbb30"  [francesitapl@hotmail.com / 1234]
                        // Óscar "a2d4e263-06f7-4653-8118-0e1c50300662" [oscar@wayapp.com / 1234]
                        // Alejo "a0e59068-0e6b-40e8-b2c9-94532553eee3"
                        // Julio "be0d9293-3902-4970-acb9-40b72c1c33ae"
                        // Café merchantUUID "53259c1c-bf1b-4298-af69-ae84052819dc"
                        // Mario "36a0d688-2bf0-465d-adba-a17a703ffd3c"
                        // Óscar NEW pan = "0E166208-803B-4CE8-8B39-9BE7A4BEFFDA"
                        if let accountUUID = session.accountUUID {
                            self.getTransactionsForAccount(accountUUID)
                        } else {
                            WayAppUtils.Log.message("Missing session.accountUUID")
                        }
                    } else {
                        WayAppPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }
        
        func getPayerForTransaction(accountUUID: String, transactionUUID: String) {
            
        }

        func getTransactionsForAccount(_ accountUUID: String) {
            WayAppPay.API.getMerchantAccountTransactions(merchantUUID, accountUUID).fetch(type: [PaymentTransaction].self) { response in
                if case .success(let response?) = response {
                    if let transactions = response.result {
                        DispatchQueue.main.async {
                            session.transactions.setToInOrder(transactions, by:
                                { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) })
                        }
                    } else {
                        WayAppPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
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
            WayAppPay.API.getMerchantAccountTransactionsForDay(merchantUUID, accountUUID, WayAppPay.reportDateFormatter.string(from: day)).fetch(type: [PaymentTransaction].self) { response in
                if case .success(let response?) = response {
                    if let transactions = response.result {
//                        DispatchQueue.main.async {
//                            session.transactions.setToInOrder(transactions, by:
//                                { ($0.creationDate ?? Date.distantPast) > ($1.creationDate ?? Date.distantPast) })
//                        }
                        print("TRANSACTIONS=\(transactions)")
                    } else {
                        WayAppPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }

        func getReportID(for accountUUID: String?, month: String) {
            guard let accountUUID = accountUUID else {
                WayAppUtils.Log.message("missing accountUUID")
                return
            }
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

        static func getMerchantsForAccount(_ accountUUID: String) {
            WayAppPay.API.getMerchants(accountUUID).fetch(type: [Merchant].self) { response in
                if case .success(let response?) = response {
                    if let merchants = response.result {
                        let count = merchants.count
                        DispatchQueue.main.async {
                            if count == 0 {
                                // Display settings Tab so user can select merchant
                                session.selectedTab = .settings
                            } else {
                                session.merchants.setTo(merchants)
                                if count == 1 {
                                    session.seletectedMerchant = 0
                                }
                            }
                        }
                    } else {
                        WayAppPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }
    }
}
