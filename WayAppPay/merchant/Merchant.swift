//
//  Merchant.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/1/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    
    struct Merchant: Codable, Identifiable, ContainerProtocol {
        
        static let defaultImageName = "questionmark.square"
        static let defaultName = "missing name"

        var merchantUUID: String
        var creationDate: Date?
        var lastUpdateDate: Date?
        
        // Protocol Identifiable
        var id: String {
            return merchantUUID
        }

        var containerID: String {
            return merchantUUID
        }

        static func loadMerchantsForAccount(_ accountUUID: String) {
            WayAppPay.API.getMerchants(accountUUID).fetch(type: [WayAppPay.Merchant].self) { response in
                if case .success(let response?) = response {
                    if let merchants = response.result {
                        DispatchQueue.main.async {
                            Session.accountData.merchants.setTo(merchants)
                            Session.merchantUUID = "53259c1c-bf1b-4298-af69-ae84052819dc" // FIXME
                        }
                    } else {
                        WayAppPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }
    }
}
