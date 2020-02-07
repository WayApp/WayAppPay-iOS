//
//  WayAppPay.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import UIKit

struct WayAppPay {
    
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale.current
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    static func priceFormatter(_ price: Int?) -> String {
        if let price = price,
            let formatted = WayAppPay.currencyFormatter.string(for: Double(price) / 100) {
            return formatted
        }
        return ""
    }

    static let appName = "WayApp Pay"

    struct Constant {
    }

}
