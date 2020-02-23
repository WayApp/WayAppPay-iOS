//
//  PaymentNFC.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/23/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import CoreNFC

extension WayAppPay {

    struct nfcPaymentHandler {
        var message: NFCNDEFMessage = .init(records: [])
        var session: NFCNDEFReaderSession?

    }
}
