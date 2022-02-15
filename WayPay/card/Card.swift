//
//  Card.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import PassKit

extension PKPass {
    var alias: String? {
        if let userInfo = self.userInfo as? [String : String],
        let alias = userInfo["alias"] {
            return alias
        }
        return nil
    }
    
    var pan: String? {
        if let userInfo = self.userInfo as? [String : String],
        let pan = userInfo["pan"] {
            return pan
        }
        return nil
    }
}

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
            case PREPAID, POSTPAID, CREDIT, DIRECT, VOUCHER, GIFTCARD, UNKNOWN
            
            var icon: String {
                switch self {
                case .PREPAID: return "banknote"
                case .POSTPAID: return "creditcard.and.123"
                case .VOUCHER: return "qrcode"
                case .GIFTCARD: return "giftcard"
                default:
                    return "questionmark.app"
                }
            }
            
            var title: String {
                switch self {
                case .PREPAID: return NSLocalizedString("prepaid", comment: "Card PaymentFormat title")
                case .POSTPAID: return NSLocalizedString("a2a", comment: "Card PaymentFormat title")
                case .VOUCHER: return NSLocalizedString("voucher", comment: "Card PaymentFormat title")
                case .GIFTCARD: return NSLocalizedString("giftcard", comment: "Card PaymentFormat title")
                default:
                    return NSLocalizedString("unknown", comment: "Card PaymentFormat title")
                }
            }

        }
        
        var pan: String
        var issuerUUID: String?
        var accountUUID: String
        var alias: String?
        var expirationDate: Date?
        var dailyLimit: Int?
        var limitPerOperation: Int?
        var currency: Currency?
        var type: PaymentFormat?
        var status: Status?
        var state: State?
        var creationDate: Date?
        var lastUpdateDate: Date?
        var consentId: String?
        var service: String?
        var iban: String?
        var issuer: Issuer?
        var balance: Balance?
        var followLink: String?
        var paymentId: String?
        var wallet: Balance?

        var pkPass: PKPass? {
            for pass in WayPayApp.session.passes {
                let userInfo = pass.userInfo as? [String : String]
                let passPAN = userInfo?["pan"]
                if passPAN == self.pan {
                    return pass
                }
            }
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
            self.accountUUID = WayPayApp.session.accountUUID ?? ""
            self.alias = alias
            self.type = type
            if let consent = consent {
                self.consentId = consent.consentId
                self.iban = consent.globalPosition[selectedIBAN].iban
            }
            self.limitPerOperation = limitPerOperation
            self.dailyLimit = limitPerOperation * 4
        }

        func getType() -> PaymentFormat {
            return type == nil ? PaymentFormat.UNKNOWN : type!
        }
        
        static func getCards(accountUUID: String, completion: @escaping ([Card]?, Error?) -> Void) {
            WayPay.API.getCards(accountUUID).fetch(type: [Card].self) { response in
                switch response {
                case .success(let response?):
                    completion(response.result, nil)
                case .failure(let error):
                    completion(nil, error)
                default:
                    completion(nil, WayPay.API.ResponseError.INVALID_SERVER_DATA)
                }
            }
        }

        static func create(alias: String = String(), issuerUUID: String, type: PaymentFormat, consent: AfterBanks.Consent? = nil, selectedIBAN: Int = 0, limitPerOperation: Int = Card.limitPerOperation, completion: @escaping (Error?, Card?) -> Void)  {
            Logger.message("********************** CARD CREATION WITH CONSENT=\(consent.debugDescription)")
            guard let accountUUID = WayPayApp.session.accountUUID else {
                Logger.message("missing Session.accountUUID")
                return
            }

            let newCard = Card(alias: alias, issuerUUID: issuerUUID, type: type, consent: consent, selectedIBAN: selectedIBAN, limitPerOperation: Card.limitPerOperation)

            WayPay.API.createCard(accountUUID, newCard).fetch(type: [Card].self) { response in
                if case .success(let response?) = response {
                    if let cards = response.result,
                        let card = cards.first {
                        Logger.message("****** DOWNLOADED CARD=\(card)")
                        completion(nil, card)
                    } else {
                        completion(WayPay.API.errorFromResponse(response), nil)
                        WayPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    completion(error, nil)
                    Logger.message(error.localizedDescription)
                }
            }
        }
        
        func hasBalance() -> Bool {
            return (type == .PREPAID) || (type == .VOUCHER) || (type == .GIFTCARD)
        }

        mutating func addIBAN(iban: String, completion: @escaping (Card?, Error?) -> Void)  {
            if let accountUUID = WayPayApp.session.accountUUID {
                self.iban = iban
                WayPay.API.editCard(accountUUID, self).fetch(type: [Card].self) { response in
                    switch response {
                    case .success(let response?):
                        completion(response.result?.first, nil)
                    case .failure(let error):
                        completion(nil, error)
                    default:
                        completion(nil, WayPay.API.ResponseError.INVALID_SERVER_DATA)
                    }
                }
            }
        }
    } // Card
}
