//
//  Prize.swift
//  WayPay
//
//  Created by Oscar Anzola on 8/10/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import Foundation

extension WayPay {
    struct Prize: Hashable, Codable, Identifiable {
        static let winnningMessage = NSLocalizedString("Congratulations. You got the prize!", comment: "winnningMessage default")
        enum Format: String, Codable, CaseIterable {
            case CASHBACK, COUPON
            
            var title: String {
                switch self {
                case .CASHBACK:
                    return NSLocalizedString("Cashback", comment: "Prize format title")
                case .COUPON:
                    return NSLocalizedString("Discount", comment: "Prize format title")
                }
            }
            
            var amountTitle: String {
                switch self {
                case .CASHBACK:
                    return NSLocalizedString("Cashback amount", comment: "Prize amountTitle")
                case .COUPON:
                    return NSLocalizedString("Discount", comment: "Prize amountTitle")
                }
            }
            
            var amountSymbol: String {
                switch self {
                case .CASHBACK:
                    return Locale.current.currencySymbol ?? "€"
                case .COUPON:
                    return "%"
                }
            }
        }
        
        var campaignID: String
        var name: String?
        var message: String
        var amountToGetIt: Int
        var value: Int?
        var format: Format
        
        init(campaignID: String, name: String, message: String = Prize.winnningMessage, format: Format = .CASHBACK, amountToGetIt: Int) {
            self.campaignID = campaignID
            self.message = message
            self.name = name
            self.format = format
            self.amountToGetIt = amountToGetIt
        }
        
        var displayAs: String {
            switch format {
            case .CASHBACK:
                return "\(WayPay.formatPrice(value))"
            case .COUPON:
                return "\(WayPay.formatAmount(value))%"
            }
        }
        
        var id: String {
            return campaignID
        }
        
        func applyToAmount(_ amount: Int) -> Int {
            switch format {
            case .CASHBACK:
                return max(amount - (value ?? 0),0)
            case .COUPON:
                return Int(Double(amount)*((value != nil) ? (1.0 - (Double(value! / 100) / 100)) : 1))
            }
        }
    }

}
