//
//  Card.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    
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
            case PREPAID, POSTPAID, CREDIT
        }
        
        var pan: String
        var issuerUUID: String
        var accountUUID: String
        var alias: String?
        //TODO: fix date format on API
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

        // Protocol Identifiable
        var id: String {
            return pan
        }

        var containerID: String {
            return pan
        }
        
        init(alias: String = String(), issuerUUID: String, type: PaymentFormat ,limitPerOperation: Int) {
            self.pan = ""
            self.issuerUUID = issuerUUID
            self.accountUUID = session.accountUUID ?? ""
            self.alias = alias
            self.type = type
            self.limitPerOperation = limitPerOperation
            self.dailyLimit = limitPerOperation * 4
        }
                
        static func create(alias: String = String(), issuerUUID: String = "f01ffb3f-5b16-4238-abf0-215c2c2c4c74", type: PaymentFormat, limitPerOperation: Int = Card.limitPerOperation, completion: @escaping (Error?, Card?) -> Void)  {
            WayAppUtils.Log.message("********************** CARD CREATION")
            guard let accountUUID = session.accountUUID else {
                WayAppUtils.Log.message("missing Session.accountUUID")
                return
            }

            let newCard = Card(alias: alias, issuerUUID: issuerUUID, type: type, limitPerOperation: Card.limitPerOperation)
            
            WayAppPay.API.createCard(accountUUID, newCard).fetch(type: [Card].self) { response in
                if case .success(let response?) = response {
                    if let cards = response.result,
                        let card = cards.first {
                        DispatchQueue.main.async {
                            session.cards.add(card)
                        }
                        completion(nil, card)
                    } else {
                        completion(WayAppPay.API.errorFromResponse(response), nil)
                        WayAppPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    completion(error, nil)
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }

        func edit(iban: String, completion: @escaping (Error?) -> Void)  {
            WayAppUtils.Log.message("********************** CARD EDIT")
            guard let accountUUID = session.accountUUID else {
                WayAppUtils.Log.message("missing Session.accountUUID")
                return
            }
            var editedCard = self
            editedCard.alias = "S10000"
            //editedCard.iban = iban
            WayAppPay.API.editCard(accountUUID, editedCard).fetch(type: [Card].self) { response in
                if case .success(let response?) = response {
                    if let cards = response.result,
                        let card = cards.first {
                        DispatchQueue.main.async {
                            session.cards.remove(self)
                            session.cards.add(card)
                        }
                        completion(nil)
                    } else {
                        completion(WayAppPay.API.errorFromResponse(response))
                        WayAppPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    completion(error)
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }

    } // Card
}
