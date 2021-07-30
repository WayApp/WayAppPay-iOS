//
//  SendEmail.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 7/2/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import Foundation

extension WayPay {
    
    struct SendEmail: Codable {
        var merchantUUID: String?
        var transactionUUID: String?
        var sendTo: String?
        var body: String?
        var subject: String?
        var transaction: PaymentTransaction?
        
        init(merchantUUID: String, transactionUUID: String, sendTo: String, transaction: PaymentTransaction, body: String = "valor por defecto", subject: String = "subject por defecto") {
            self.merchantUUID = WayPay.session.merchantUUID
            self.transactionUUID = transactionUUID
            self.sendTo = sendTo
            self.transaction = transaction
        }
        
        init(transaction: PaymentTransaction, sendTo: String) {
            self.merchantUUID = transaction.merchantUUID
            self.transactionUUID = transaction.transactionUUID
            self.sendTo = sendTo
            self.transaction = transaction

        }
        
        static func process(transaction: PaymentTransaction, sendTo: String) {
            let sendEmail = SendEmail(transaction: transaction, sendTo: sendTo)
            guard let merchantUUID = transaction.merchantUUID, let transactionUUID = transaction.transactionUUID else {
                WayAppUtils.Log.message("Missing merchantUUID or transactionUUID")
                return
            }
            WayPay.API.sendEmail(merchantUUID, transactionUUID, sendEmail).fetch(type: [SendEmail].self) { response in
                if case .success(let response?) = response {
                    WayAppUtils.Log.message("Email sent !!!!=\(response)")
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }
        
    }
    
}

