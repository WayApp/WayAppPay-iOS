//
//  Merchant.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/1/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    
    struct Merchant: Codable, Identifiable, ContainerProtocol, Equatable, Hashable {
        
        static func ==(ls: Merchant, rs: Merchant) -> Bool {
            return ls.merchantUUID == rs.merchantUUID
        }

        static let defaultImageName = "questionmark.square"
        static let defaultName = "missing name"

        var merchantUUID: String
        var name: String?
        var description: String?
        var email: String?
        var address: Address?
        var website: String?
        var identityDocument: IdentityDocument?
        var logo: String?
//        var creationDate: Date?
//        var lastUpdateDate: Date?
//        var currency: Currency?
        
        init(name: String) {
            self.merchantUUID = UUID().uuidString
            self.name = name
            self.description = name
        }

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
                            if merchants.isEmpty {
                                // Display settings Tab so user can select merchant
                                session.selectedTab = .settings
                            } else {
                                session.merchants.setTo(merchants)
                            }
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
