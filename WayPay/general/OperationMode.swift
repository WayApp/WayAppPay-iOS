//
//  OperationMode.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import Foundation

enum OperationMode {
    case customer, merchant, user, waypay
    
    static var current: OperationMode = .waypay
    
    static var isWayPay: Bool {
        return current == .waypay
    }
    
    static var isCommunity: Bool {
        return current == .customer || current == .waypay
    }
    
    static var shouldRetrievePasses: Bool {
        return current == .user || current == .waypay
    }
}
