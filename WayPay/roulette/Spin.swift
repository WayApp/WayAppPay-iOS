//
//  Spin.swift
//  WayPay
//
//  Created by Oscar Anzola on 14/3/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import Foundation

extension WayPay {
    struct Spin: Hashable, Codable, Identifiable, ContainerProtocol {
        var issuerUUID: String
        var rouletteUUID: String
        var result: Int?
        var token: String?

        // Protocol Identifiable
        var id: String {
            return rouletteUUID
        }
                
    }
}
