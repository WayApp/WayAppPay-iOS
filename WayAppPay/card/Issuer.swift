//
//  Issuer.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    
    struct Issuer: Hashable, Codable, Identifiable, ContainerProtocol {
        var issuerUUID: String
        var foregroundColor: String
        var labelColor: String
        var backgroundColor: String
        var passTypeIdentifier: String
        var certApple: String
        var aliasCertApple: String
        var certPassword: String
        var name: String
        var description: String?
        var iconURL: String
        var logoURL: String
        var stripURL: String
        var creationDate: Date
        var lastUpdateDate: Date
        
        // Protocol Identifiable
        var id: String {
            return issuerUUID
        }

        var containerID: String {
            return issuerUUID
        }
        
        static func get() {
            WayAppPay.API.getIssuers.fetch(type: [Issuer].self) { response in
                if case .success(let response?) = response {
                    if let issuers = response.result {
                        DispatchQueue.main.async {
                            session.issuers.setTo(issuers)
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
