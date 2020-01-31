//
//  Product.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    
    struct Product: Codable, Identifiable {
        
        static let defaultImageName = "questionmark.square"
        static let defaultName = "missing name"

        var productUUID: String?
        var merchantUUID: String?
        var name: String?
        var description: String?
        var iva: Double?
        var price: Int?
        var image: String?
        var barcode: String?
        var keywords: [String]?
        var creationDate: Date?
        var lastUpdateDate: Date?
        
        // Protocol Identifiable
        var id: String {
            return productUUID ?? UUID().uuidString
        }

    }
}
