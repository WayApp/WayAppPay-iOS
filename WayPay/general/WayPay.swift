//
//  WayAppPay.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import SwiftUI
import AVFoundation


class WayPay: ObservableObject {
    static let acceptedPaymentCodes: [AVMetadataObject.ObjectType] = [.qr, .code128]
    static let appName = "WayPay"
    static let passTypeIdentifier = "pass.com.wayapp.pay"
    
}
