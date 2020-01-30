//
//  Address.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    
    struct Address: Codable {
        var line1: String?
        var city: String?
        var stateProvince: String?
        var country: String?
        var postalCode: String?
        var formatted: String {
            if let line1 = line1,
                let city = city {
                return "\(line1) \(postalCode ?? "") \(city), \(stateProvince ?? "")"
            } else {
                return "-"
            }
        }
    }

}
