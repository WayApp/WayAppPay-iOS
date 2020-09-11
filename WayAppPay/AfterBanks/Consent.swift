//
//  Consent.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 07/09/2020.
//  Copyright © 2020 WayApp. All rights reserved.
//

import Foundation

extension AfterBanks {
    struct GlobalPosition: Codable {
        var product: String?
        var type: String?
        var description: String?
        var iban: String?
        var balance: Double?
        var currency: String?
    }
    
    struct ConsentRequest: Codable {
        var service: String // key
        var validUntil: String // dd-mm-aaaa
        var urlRedirect: String
        var pan: String
    }
    
    struct Consent: Codable, Identifiable, ContainerProtocol {
        var consentId: String
        var token: String
        var globalPosition: [GlobalPosition];
        
        // Protocol Identifiable
        var id: String {
            return consentId
        }

        var containerID: String {
            return consentId
        }
    }
}
