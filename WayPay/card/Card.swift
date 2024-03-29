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
                        
        static func getCards(for accountUUID: String) {
            WayPay.API.getCards(accountUUID).fetch(type: [Card].self) { response in
                if case .success(let response?) = response {
                    if let cards = response.result {
                        DispatchQueue.main.async {
                            session.cards.setTo(cards)
                        }
                    } else {
                        WayPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }

        static func create(alias: String = String(), issuerUUID: String, type: PaymentFormat, consent: AfterBanks.Consent? = nil, selectedIBAN: Int = 0, limitPerOperation: Int = Card.limitPerOperation, completion: @escaping (Error?, Card?) -> Void)  {
            WayAppUtils.Log.message("********************** CARD CREATION WITH CONSENT=\(consent.debugDescription)")
            guard let accountUUID = session.accountUUID else {
                WayAppUtils.Log.message("missing Session.accountUUID")
                return
            }

            let newCard = Card(alias: alias, issuerUUID: issuerUUID, type: type, consent: consent, selectedIBAN: selectedIBAN, limitPerOperation: Card.limitPerOperation)

            WayPay.API.createCard(accountUUID, newCard).fetch(type: [Card].self) { response in
                if case .success(let response?) = response {
                    if let cards = response.result,
                        let card = cards.first {
                        WayAppUtils.Log.message("****** DOWNLOADED CARD=\(card)")
                        DispatchQueue.main.async {
                            session.cards.add(card)
                        }
                        
                        completion(nil, card)
                    } else {
                        completion(WayPay.API.errorFromResponse(response), nil)
                        WayPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    completion(error, nil)
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }

        func edit(iban: String, completion: @escaping (Error?) -> Void)  {
            guard let accountUUID = session.accountUUID else {
                WayAppUtils.Log.message("missing Session.accountUUID")
                return
            }
            var editedCard = self
            editedCard.alias = "S10000"
            //editedCard.iban = iban
            WayPay.API.editCard(accountUUID, editedCard).fetch(type: [Card].self) { response in
                if case .success(let response?) = response {
                    if let cards = response.result,
                        let card = cards.first {
                        DispatchQueue.main.async {
                            session.cards.remove(self)
                            session.cards.add(card)
                        }
                        completion(nil)
                    } else {
                        completion(WayPay.API.errorFromResponse(response))
                        WayPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    completion(error)
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }
        
        static func delete(at offsets: IndexSet) {
            guard let accountUUID = session.accountUUID else {
                WayAppUtils.Log.message("missing Session.accountUUID")
                return
            }
            for offset in offsets {
                WayPay.API.deleteCard(accountUUID, session.cards[offset].pan).fetch(type: [String].self) { response in
                    if case .success(_) = response {
                        DispatchQueue.main.async {
                            session.cards.remove(session.cards[offset])
                        }
                    } else if case .failure(let error) = response {
                        WayAppUtils.Log.message(error.localizedDescription)
                    }
                }
            }
        }
    } // Card
}
