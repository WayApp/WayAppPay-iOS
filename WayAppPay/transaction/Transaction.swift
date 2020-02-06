//
//  Transaction.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    
    struct Transaction: Codable, ContainerProtocol, Identifiable {
        enum TransactionType: String, Codable {
            case SALE
            case REFUND
            case ADD
        }

        enum TransactionResult: String, Codable {
            case DENIED, ACCEPTED, PROCESSING
        }

        struct PurchaseDetail: Codable {
            let name: String?
            let price: Int?
            let quantity: Double?
        }
        
        enum ReadingType: String, Codable {
            case STANDARD, BACKUP, TPV_SANTANDER, TPV_PAY, PAYPAL, STRIPE, STRIPE_CARDS, STRIPE_SEPA
        }

        enum PaymentMethod: String, Codable {
            case WALLET, CARD_PINPAD, CASH, TICKET, OTHER, PAYPAL, STRIPE
        }

        var transactionUUID: String
        var merchantUUID: String?
        var accountUUID: String?
        var pan: String?
        var authorizationCode: String?
        var type: TransactionType?
        var result: TransactionResult?
        var purchaseDetail: [PurchaseDetail]?
        var readingType: ReadingType?
        var paymentMethod: PaymentMethod?
        var amount: Int?
        var currency: Currency?
        var origin: String?
        var receiptImage: String?
        var refund: Bool?
        var creationDate: Date?
        var lastUpdateDate: Date?
        
        var id: String {
            return transactionUUID
        }
        
        var containerID: String {
            return transactionUUID
        }
        
        // This init only used for debugging
        init(amount: Int) {
            self.transactionUUID = UUID().uuidString
            self.accountUUID = "no account"
            self.merchantUUID = "no merchant"
            self.amount = amount
            self.creationDate = Date()
        }
    }
}
