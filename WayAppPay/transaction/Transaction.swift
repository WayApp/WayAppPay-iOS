//
//  PaymentTransaction.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

/* test commit push */
extension WayAppPay {
    struct PaymentTransaction: Codable, ContainerProtocol, Identifiable {
        
        static let defaultCurrency = Currency.EUR
        
        enum TransactionType: String, Codable {
            case SALE
            case REFUND
            case ADD
        }

        enum TransactionResult: String, Codable {
            case DENIED, ACCEPTED, PROCESSING
        }
        
        enum ReadingType: String, Codable {
            case STANDARD, BACKUP, TPV_SANTANDER, TPV_PAY, PAYPAL, STRIPE, STRIPE_CARDS, STRIPE_SEPA
        }

        enum PaymentMethod: String, Codable {
            case WALLET, CARD_PINPAD, CASH, TICKET, OTHER, PAYPAL, STRIPE
        }

        var transactionUUID: String?
        var merchantUUID: String?
        var accountUUID: String?
        var pan: String?
        var authorizationCode: String?
        var type: TransactionType?
        var result: TransactionResult?
        var purchaseDetail: [CartItem]?
        var readingType: ReadingType?
        var paymentMethod: PaymentMethod?
        var amount: Int?
        var currency: Currency?
        var origin: String?
        var receiptImage: String?
        var refund: Bool?
        var creationDate: Date?
        var lastUpdateDate: Date?
        var paymentId: String?
        var follow: String?

        var id: String {
            return transactionUUID ?? UUID().uuidString
        }
        
        var containerID: String {
            return transactionUUID ?? UUID().uuidString
        }
        
        var isRefund: Bool {
            return refund ?? false
        }
                
        // Payment with Wallet card
        init(amount: Int, token: String = String(), type: TransactionType = .SALE) {
            self.accountUUID = session.accountUUID
            self.merchantUUID = session.merchantUUID
            self.amount = amount
            self.authorizationCode = token
            self.paymentMethod = .WALLET
            self.type = type
            self.currency = session.merchants.isEmpty ?  PaymentTransaction.defaultCurrency : session.merchants[session.seletectedMerchant].currency
            self.readingType = .STANDARD
            self.merchantUUID = session.merchantUUID
            self.accountUUID = session.accountUUID
        }
        
        func walletPayment() {
            guard let merchantUUID = self.merchantUUID,
                let accountUUID = self.accountUUID else {
                WayAppUtils.Log.message("missing transaction.merchantUUID or transaction.accountUUID")
                return
            }
            WayAppPay.API.walletPayment(merchantUUID, accountUUID, self).fetch(type: [WayAppPay.PaymentTransaction].self) { response in
                if case .success(let response?) = response {
                    if let transactions = response.result,
                        let transaction = transactions.first {
                        DispatchQueue.main.async {
                            session.transactions.addAsFirst(transaction)
                        }
                        WayAppUtils.Log.message("PAGO HECHO!!!!=\(transaction)")
                    } else {
                        WayAppPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }

        func processRefund() -> Void {
            guard let merchantUUID = self.merchantUUID,
                let accountUUID = self.accountUUID,
                let transactionUUID = self.transactionUUID else {
                WayAppUtils.Log.message("missing transaction.merchantUUID or transaction.accountUUID")
                return
            }
            WayAppPay.API.refundTransaction(merchantUUID, accountUUID, transactionUUID, self).fetch(type: [PaymentTransaction].self) { response in
                if case .success(let response?) = response {
                    if let transactions = response.result,
                        let transaction = transactions.first {
                        DispatchQueue.main.async {
                            WayAppPay.session.transactions.addAsFirst(transaction)
                            WayAppPay.session.refundState = .success
                        }
                        WayAppUtils.Log.message("REFUND HECHO!!!!=\(transaction)")
                    } else {
                        DispatchQueue.main.async {
                            WayAppPay.session.refundState = .failure
                        }
                        WayAppPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    DispatchQueue.main.async {
                        WayAppPay.session.refundState = .failure
                    }
                    WayAppUtils.Log.message(error.localizedDescription)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + WayAppPay.UI.paymentResultDisplayDuration) {
                    WayAppPay.session.refundState = .none
                }
            }
        }
    
    }
}
