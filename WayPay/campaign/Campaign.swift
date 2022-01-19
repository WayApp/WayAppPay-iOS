//
//  Campaign.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/5/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

extension WayPay {
        
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
        var paymentAmountConvertibleToUnit: Int? // payment amount that accounts to 1 point or 1 euro
        var minimumPaymentAmountRequired: Int? // specifies a minimum payment necessary to get a unit of prize
        var prize: Prize?

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
    
        static func create(_ campaign: Campaign, completion: @escaping ([Campaign]?, Error?) -> Void) {
            WayPay.API.createCampaign(campaign).fetch(type: [Campaign].self) { response in
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

        static func update(_ campaign: Campaign, completion: @escaping ([Campaign]?, Error?) -> Void) {
            WayPay.API.updateCampaign(campaign).fetch(type: [Campaign].self) { response in
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

        static func prizesForReward(_ reward: Reward) -> [Prize] {
            var wonPrizes = [Prize]()
            if let balance = reward.balance,
               let campaign = WayPayApp.session.campaigns[reward.campaignID],
               let prize = campaign.prize {
                Logger.message("Balance: \(balance), prize.amountToGetIt: \(prize.amountToGetIt)")
                if prize.amountToGetIt <= balance {
                    wonPrizes.append(prize)
                }
            }
            return wonPrizes
        }

        static func get(merchantUUID: String?, issuerUUID: String?, completion: @escaping ([Campaign]?, Error?) -> Void) {
            WayPay.API.getCampaigns(merchantUUID, issuerUUID).fetch(type: [Campaign].self) { response in
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
            WayPay.API.getCampaign(campaignID, sponsorUUID).fetch(type: [Campaign].self) { response in
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
            WayPay.API.getCampaignsForIssuer(merchantUUID, issuerUUID).fetch(type: [Campaign].self) { response in
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
            WayPay.API.toggleCampaignState(self.id, self.sponsorUUID).fetch(type: [Campaign].self) { response in
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
        
        static func delete(id: String, sponsorUUID: String) {
            WayPay.API.deleteCampaign(id, sponsorUUID).fetch(type: [String].self) { response in
                if case .success(_) = response {
                    Logger.message("Campaign with ID=\(id) successfully deleted")
                } else if case .failure(let error) = response {
                    Logger.message(error.localizedDescription)
                }
            }
        }
        
        static func sendPushNotification(id: String, pushNotification: PushNotification, completion: @escaping ([PushNotification]?, Error?) -> Void) {
            Logger.message("Sending campaign pushNotification with text: \(pushNotification.text)")
            WayPay.API.sendPushNotificationForCampaign(id, pushNotification).fetch(type: [PushNotification].self) { response in
                Logger.message("Campaign: sendPushNotification: responded: \(response)")
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
                
        static func icon(format: Format) -> String {
            switch format {
            case .POINT:
                return "plus.rectangle.fill"
            case .STAMP:
                return "square.grid.3x3.topleft.filled"
            }
        }

        func icon() -> String {
            Campaign.icon(format: format)
        }

        static func activeCampaignWithFormat(_ format: Campaign.Format, campaigns: Container<Campaign>?) -> Campaign? {
            guard let campaigns = campaigns else {
                return nil
            }
            for campaign in campaigns where campaign.format == format {
                return campaign
            }
            return nil
        }

    }
}
