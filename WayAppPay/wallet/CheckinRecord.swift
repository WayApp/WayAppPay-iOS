//
//  CheckinRecord.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 6/23/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    
    struct CheckinRecord: Codable {
        let creationDate: Date
        let checkinUUID: String
        let serialNo: String
        let checkinInfo: [String: String]?
    }
}
