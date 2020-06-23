//
//  Checkin.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 6/23/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    
    struct Checkin: Codable {
        let maxUses: Int
        let uses: Int
    }
}
