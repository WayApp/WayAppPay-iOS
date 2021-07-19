//
//  Checkin.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 19/7/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    
    struct Checkin: Codable {
        var accountUUID: String
        var firstName: String?
        var lastName: String?
        var transactions: [WayAppPay.PaymentTransaction]?
        var rewards: [WayAppPay.Reward]?
        var prizes: [WayAppPay.Prize]?
        
    }
}
