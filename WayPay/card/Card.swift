//
//  Card.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import PassKit

extension WayPay {
    
    struct Card: Codable, Identifiable, ContainerProtocol {
        static let defaultImageName = "creditcard"
        static let defaultName = "Payment Token"
        static let limitPerOperation = 2500000
        static let dailyLimit = limitPerOperation * 4
        
        enum Status: String, Codable {
            case ENABLED, BLOCKED
        }

        enum State: String, Codable {
            case ON, OFF
        }

        public enum PaymentFormat: String, Codable, CaseIterable {
            case PREPAID, POSTPAID, CREDIT, DIRECT, VOUCHER, GIFTCARD
        }
        
        var pan: String
        var issuerUUID: String
        var accountUUID: String
        var alias: String?
//        var expirationDate: Date?
        var dailyLimit: Int?
        var limitPerOperation: Int?
        var currency: Currency?
        var type: PaymentFormat?
        var status: Status?
        var state: State?
        var creationDate: Date?
        var lastUpdateDate: Date?
        var consentId: String?
        var iban: String?
        var issuer: Issuer?
        var balance: Balance?
        var followLink: String?
        var paymentId: String?
        var wallet: Balance?
        var pkPass: PKPass? {
            for pass in session.passes {
                let userInfo = pass.userInfo as? [String : String]
                WayAppUtils.Log.message("+ userInfo: \(userInfo.debugDescription)")

                let passPAN = userInfo?["pan"]
                if passPAN == self.pan {
                    WayAppUtils.Log.message("+ FOUND MATCHING PAN FOR CARD: \(alias ?? "NO ALIAS"), \(passPAN ?? "NO PAN")")
                    return pass
                } else {
                    WayAppUtils.Log.message("+ NO MATCH: \(alias ?? "NO ALIAS"), \(passPAN ?? "NO PAN"), and \(self.pan)")
                }
            }
            WayAppUtils.Log.message("+ DID NOT FIND MATCHING PAN FOR CARD: \(alias ?? "NO ALIAS"), \(self.pan)")
            return nil
        }

        // Protocol Identifiable
        var id: String {
            return pan
        }

        init() {
            self.alias = "Sample card"
            self.pan = UUID().uuidString
            self.issuerUUID = UUID().uuidString
            self.accountUUID = UUID().uuidString
        }
        
        init(alias: String = String(), issuerUUID: String, type: PaymentFormat, consent: AfterBanks.Consent?, selectedIBAN: Int, limitPerOperation: Int) {
            self.pan = ""
            self.issuerUUID = issuerUUID
            self.accountUUID = session.accountUUID ?? ""
            self.alias = alias
            self.type = type
            if let consent = consent {
                self.consentId = consent.consentId
                self.iban = consent.globalPosition[selectedIBAN].iban
            }
            self.limitPerOperation = limitPerOperation
            self.dailyLimit = limitPerOperation * 4
        }
                        
        
    } // Card
}
