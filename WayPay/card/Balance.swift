//
//  Balance.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 06/09/2020.
//  Copyright © 2020 WayApp. All rights reserved.
//

import Foundation

extension WayPay {
    
    struct Balance: Codable, Identifiable, ContainerProtocol {
        var pan: String
        var balance: Int?
        var creationDate: Date?
        var lastUpdateDate: Date?
        
        // Protocol Identifiable
        var id: String {
            return pan
        }

        init(balance: Int = 100000) {
            self.pan = UUID().uuidString
            self.balance = balance
        }

    } // Card
    
}
