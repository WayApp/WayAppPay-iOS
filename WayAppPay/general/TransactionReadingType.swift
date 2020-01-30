//
//  File.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    
    enum TransactionReadingType: String, Codable {
        case STANDARD
        case BACKUP
        case TPV_SANTANDER
        case TPV_PAY
        case PAYPAL
        case STRIPE
        case STRIPE_CARDS
        case STRIPE_SEPA
    }
}
