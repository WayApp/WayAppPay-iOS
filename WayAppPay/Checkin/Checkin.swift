//
//  Checkin.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 19/7/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import Foundation

extension WayPay {
    
    struct Checkin: Codable {
        var accountUUID: String
        var firstName: String?
        var lastName: String?
        var transactions: [WayPay.PaymentTransaction]?
        var rewards: [WayPay.Reward]?
        var prizes: [WayPay.Prize]?
        
    }
}
