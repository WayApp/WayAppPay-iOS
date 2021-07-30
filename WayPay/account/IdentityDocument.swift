//
//  IdentityDocument.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

extension WayPay {
    
    struct IdentityDocument: Codable, Hashable {
        enum Document: String, Codable {
            case PASSPORT, DRIVER_LICENSE, PERSONAL_ID, TAX_ID
        }
        
        let number: String?
        let type: Document?
        let images: [String]?
        
        static func ==(ls: IdentityDocument, rs: IdentityDocument) -> Bool {
            return (ls.type == rs.type) && (ls.number == rs.number)
        }

    }
}
