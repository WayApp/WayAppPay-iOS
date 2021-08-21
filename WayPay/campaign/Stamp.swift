//
//  Stamp.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/7/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import Foundation

extension WayPay {
    class Stamp: Campaign {
        var minimumPaymentAmountToGetStamp: Int?
        var prize: Prize?
        private enum CodingKeys: String, CodingKey {
            case minimumPaymentAmountToGetStamp
            case prize
        }

        init(campaign: Campaign, minimumPaymentAmountToGetStamp: Int, prize: Prize) {
            super.init(campaign: campaign)
            self.minimumPaymentAmountToGetStamp = minimumPaymentAmountToGetStamp
            self.prize = prize
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try super.init(from: decoder)
            do {
                minimumPaymentAmountToGetStamp = try container.decode(Int.self, forKey: .minimumPaymentAmountToGetStamp)
                prize = try container.decode(Prize.self, forKey: .prize)
            } catch {
                WayAppUtils.Log.message("Missing minimumPaymentAmountToGetStamp or prize")
            }

        }
        
        override func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            do {
                try container.encode(minimumPaymentAmountToGetStamp, forKey: .minimumPaymentAmountToGetStamp)
                try container.encode(prize, forKey: .prize)
                try super.encode(to: encoder)
            } catch {
                WayAppUtils.Log.message("Missing minimumPaymentAmountToGetStamp or prize")
            }
        }

        static func create(_ campaign: Stamp, completion: @escaping ([Stamp]?, Error?) -> Void) {
            WayPay.API.createStampCampaign(campaign).fetch(type: [Stamp].self) { response in
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

        static func update(_ campaign: Stamp, completion: @escaping ([Stamp]?, Error?) -> Void) {
            WayPay.API.updateStampCampaign(campaign).fetch(type: [Stamp].self) { response in
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
               let prize = session.stamps[reward.campaignID]?.prize {
                WayAppUtils.Log.message("Balance: \(balance), prize.amountToGetIt: \(prize.amountToGetIt)")
                if prize.amountToGetIt <= balance {
                    wonPrizes.append(prize)
                }
            }
            return wonPrizes
        }
        
        static func isStampCampaignActive() -> Bool {
            if (session.stamps.isEmpty || session.stamps.first?.state != .ACTIVE) {
                return false
            }
            return true
        }

        static func isIssuerStampCampaignActive() -> Bool {
            if let checkin = session.checkin,
               let issuerStampCampaigns = checkin.issuerStampCampaigns,
               !issuerStampCampaigns.isEmpty {
                return true
            }
            return false
        }
    }
}
