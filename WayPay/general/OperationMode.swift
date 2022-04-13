//
//  OperationMode.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import Foundation

enum OperationMode {
    case CUSTOMER, MERCHANT, USER, WAYPAY
    
    static var current: OperationMode = .WAYPAY
    
    static var isWayPay: Bool {
        return current == .WAYPAY
    }
    
    static var isCommunity: Bool {
        return current == .CUSTOMER || current == .WAYPAY
    }
    
    static var shouldRetrievePasses: Bool {
        return current == .USER || current == .WAYPAY
    }
}
