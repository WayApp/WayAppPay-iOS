//
//  Campaign.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/5/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

extension WayPay {
    
    struct Prize: Hashable, Codable, Identifiable {
        static let winnningMessage = NSLocalizedString("Congratulations. You got the prize!", comment: "winnningMessage default")
        enum Format: String, Codable, CaseIterable {
            case CASHBACK, COUPON
            
            var title: String {
                switch self {
                case .CASHBACK:
                    return NSLocalizedString("Cashback", comment: "Prize format title")
                case .COUPON:
                    return NSLocalizedString("Discount", comment: "Prize format title")
                }
            }
            
            var amountTitle: String {
                switch self {
                case .CASHBACK:
                    return NSLocalizedString("Cashback amount", comment: "Prize amountTitle")
                case .COUPON:
                    return NSLocalizedString("Discount", comment: "Prize amountTitle")
                }
            }
            
            var amountSymbol: String {
                switch self {
                case .CASHBACK:
                    return Locale.current.currencySymbol ?? "€"
                case .COUPON:
                    return "%"
                }
            }

        }
        
        var campaignID: String
        var name: String?
        var message: String
        var amountToGetIt: Int
        var value: Int?
        var format: Format
        
        init(campaignID: String, name: String, message: String = Prize.winnningMessage, format: Format = .CASHBACK, amountToGetIt: Int) {
            self.campaignID = campaignID
            self.message = message
            self.name = name
            self.format = format
            self.amountToGetIt = amountToGetIt
        }
        
        var displayAs: String {
            switch format {
            case .CASHBACK:
                return "\(name ?? "-"): \(WayPay.formatPrice(value))"
            case .COUPON:
                return "\(name ?? "-"): \(WayPay.formatAmount(value))%"
            }
        }
        
        var id: String {
            return campaignID
        }
        
        func applyToAmount(_ amount: Int) -> Int {
            WayAppUtils.Log.message("amount=\(amount)")
            switch format {
            case .CASHBACK:
                return max(amount - (value ?? 0),0)
            case .COUPON:
                WayAppUtils.Log.message("amount=\(Int(Double(amount)*((value != nil) ? (1.0 - (Double(value! / 100) / 100)) : 1)))")
                return Int(Double(amount)*((value != nil) ? (1.0 - (Double(value! / 100) / 100)) : 1))
            }
        }
    }

    struct Reward: Hashable, Codable, Identifiable {
        var accountUUID: String
        var campaignID: String
        var format: Campaign.Format?
        var sponsorUUID: String?
        var creationDate: Date?
        var lastUpdateDate: Date?
        var lastTransactionUUID: String?
        var balance: Int?
        
        var id: String {
            return campaignID
        }

    }
    
    class Campaign: Hashable, Codable, Identifiable, Equatable, ContainerProtocol {
        
        static func == (lhs: Campaign, rhs: Campaign) -> Bool {
            return (lhs.id == rhs.id) && (lhs.sponsorUUID == rhs.sponsorUUID)
        }
        
        static func <(lhs: Campaign, rhs: Campaign) -> Bool {
            return (lhs.state.rawValue < rhs.state.rawValue)
        }

        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(sponsorUUID)
        }

        enum Format: String, Codable { //
            case STAMP, POINT
        }

        enum State: String, Codable {
            case ACTIVE, INACTIVE, EXPIRED
            
            var color: Color {
                switch self {
                case .ACTIVE:
                    return .green
                case .INACTIVE:
                    return .red
                case .EXPIRED:
                    return .black
                }
            }
            
            var icon: String {
                return "circle.fill"
            }
        }

        var sponsorUUID: String
        var id: String
        var name: String
        var format: Format
        var state: State = .ACTIVE
        var description: String?
        var expirationDate: Date?
        var creationDate: Date?
        var lastUpdateDate: Date?
                
        init(name: String, description: String = "", sponsorUUID: String, format: Format, expirationDate: Date = Date.distantFuture, state: State = .ACTIVE) {
            self.id = UUID().uuidString
            self.name = name
            self.description = description
            self.sponsorUUID = sponsorUUID
            self.format = format
            self.expirationDate = expirationDate
            self.state = state
        }
        
        init(campaign: Campaign) {
            self.id = UUID().uuidString
            self.name = campaign.name
            self.description = campaign.description
            self.sponsorUUID = campaign.sponsorUUID
            self.format = campaign.format
            self.expirationDate = campaign.expirationDate
            self.state = campaign.state
        }
        
        init() {
            self.id = UUID().uuidString
            self.name = "Sample name"
            self.description = "Sample description"
            self.sponsorUUID = "1234567890"
            self.format = Format.POINT
            self.state = State.ACTIVE
        }
        
        static func get<T: Campaign>(merchantUUID: String, issuerUUID: String?, campaignType: T.Type, format: Format, completion: @escaping ([T]?, Error?) -> Void) {
            WayPay.API.getCampaigns(merchantUUID, issuerUUID, format).fetch(type: [T].self) { response in
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

        static func get(campaignID: String, sponsorUUID: String, format: Format, completion: @escaping ([Campaign]?, Error?) -> Void) {
            WayPay.API.getCampaign(campaignID, sponsorUUID, format).fetch(type: [Campaign].self) { response in
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
        
        static func getForIssuer(merchantUUID: String, issuerUUID: String, format: Format, completion: @escaping ([Campaign]?, Error?) -> Void) {
            WayPay.API.getCampaignsForIssuer(merchantUUID, issuerUUID, format).fetch(type: [Campaign].self) { response in
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


        static func reward(transaction: PaymentTransaction, campaignIDs: Array<String>, completion: @escaping ([Campaign]?, Error?) -> Void) {
            WayPay.API.rewardCampaigns(transaction, campaignIDs).fetch(type: [Campaign].self) { response in
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
        
        static func reward(transaction: PaymentTransaction, campaign: Campaign, completion: @escaping ([PaymentTransaction]?, Error?) -> Void) {
            WayPay.API.rewardCampaign(transaction, campaign).fetch(type: [PaymentTransaction].self) { response in
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


        static func redeem(transaction: PaymentTransaction, campaignIDs: Array<String>, completion: @escaping ([Campaign]?, Error?) -> Void) {
            WayPay.API.redeemCampaigns(transaction, campaignIDs).fetch(type: [Campaign].self) { response in
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

        func toggleState(completion: @escaping ([Campaign]?, Error?) -> Void) {
            WayPay.API.toggleCampaignState(self.id, self.sponsorUUID, self.format).fetch(type: [Campaign].self) { response in
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
        
        static func delete(id: String, sponsorUUID: String, format: Format, completion: @escaping ([String]?, Error?) -> Void) {
            WayPay.API.deleteCampaign(id, sponsorUUID, format).fetch(type: [String].self) { response in
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
        
        static func delete(at offsets: IndexSet) {
            WayAppUtils.Log.message("Entering")
            for offset in offsets {
                WayPay.Campaign.delete(id: session.campaigns[offset].id, sponsorUUID: session.campaigns[offset].sponsorUUID, format: session.campaigns[offset].format) { strings, error in
                    if let error = error {
                        WayAppUtils.Log.message("Campaign: \(session.campaigns[offset].name) could not be . Error: \(error.localizedDescription)")
                    } else {
                        WayAppUtils.Log.message("DELETED SUCCESSFULLY")
                        WayAppUtils.Log.message("Campaign: \(session.campaigns[offset].name) deleted successfully")
                        DispatchQueue.main.async {
                            WayAppUtils.Log.message("Before total stamps: \(session.campaigns.count)")
                            session.campaigns.remove(session.campaigns[offset])
                            // TODO: remove from POINTS and STAMPS containers
                            WayAppUtils.Log.message("After total stamps: \(session.campaigns.count)")
                        }
                    }
                }
            }
        }
        
        static func prizesForRewards(_ rewards: [Reward]) -> [Prize] {
            var prizes = [Prize]()
            for reward in rewards {
                if let format = session.campaigns[reward.campaignID]?.format {
                    switch format {
                    case .POINT:
                        prizes.append(contentsOf: Point.prizesForReward(reward))
                    case .STAMP:
                        prizes.append(contentsOf: Stamp.prizesForReward(reward))
                    }
                }
            }
            return prizes
        }

        static func icon(format: Format) -> String {
            switch format {
            case .POINT:
                return "banknote"
            case .STAMP:
                return "circle.grid.3x3"
            }
        }

        func icon() -> String {
            Campaign.icon(format: format)
        }

    }
}
