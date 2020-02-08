//
//  WayAppPay.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import AVFoundation
import SwiftUI

struct WayAppPay {
    
    struct UI {
        static let paymentResultSuccessImage = "checkmark.circle.fill"
        static let paymentResultFailureImage = "x.circle.fill"
        static let paymentResultImageSize: CGFloat = 220.0
        static let paymentResultDisplayDuration: TimeInterval = 1.5
        static let shoppingCartRowImageSize: CGFloat = 36.0
    }
    
    static let acceptedPaymentCodes: [AVMetadataObject.ObjectType] = [.qr, .code128]

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
