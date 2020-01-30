//
//  Transaction.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    
    struct Transaction: Codable {
        
        enum TransactionType: String, Codable {
            case SALE
            case REFUND
            case ADD
        }

        enum TransactionResult: String, Codable {
            case DENIED
            case ACCEPTED
            case PROCESSING
        }

        var transactionUUID: String?
        var merchantUUID: String?
        var accountUUID: String?
        var pan: String?
        var authorizationCode: String?
        var type: TransactionType?
        var result: TransactionResult?
        var purchaseDetail: [Product]?
        var readingType: TransactionReadingType?
        var paymentMethod: PaymentMethod?
        var amount: Int?
        var currency: Currency?
        var origin: String?
        var receiptImage: String?
        var refund: Bool?
        var creationDate: Date?
        var lastUpdateDate: Date?

    }
}
