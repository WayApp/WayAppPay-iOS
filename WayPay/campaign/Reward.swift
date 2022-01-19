//
//  Reward.swift
//  WayPay
//
//  Created by Oscar Anzola on 8/10/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import Foundation

extension WayPay {
    struct Reward: Hashable, Codable, Identifiable {
        var accountUUID: String
        var campaignID: String
        var format: Campaign.Format?
        var sponsorUUID: String?
        var creationDate: Date?
        var lastUpdateDate: Date?
        var lastTransactionUUID: String?
        var balance: Int?
        
        var id: String {
            return campaignID
        }
        
        var getFormattedBalance: String {
            if let format = format {
                switch format {
                case .STAMP: return String(balance ?? 0)
                case .POINT: return UI.formatAmount(balance)
                }
            }
            return ""
        }
    }

}
