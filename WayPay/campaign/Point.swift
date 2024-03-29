//
//  Point.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/7/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import Foundation

extension WayPay {
    class Point: Campaign {
        var paymentAmountConvertibleToRewardUnit: Int?
        var prizes: [Prize]?
        private enum CodingKeys: String, CodingKey {
            case paymentAmountConvertibleToRewardUnit
            case prizes
        }
        
        init(campaign: Campaign, paymentAmountConvertibleToRewardUnit: Int, prizes: [Prize]) {
            super.init(campaign: campaign)
            self.paymentAmountConvertibleToRewardUnit = paymentAmountConvertibleToRewardUnit
            self.prizes = prizes
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try super.init(from: decoder)
            do {
                paymentAmountConvertibleToRewardUnit = try container.decode(Int.self, forKey: .paymentAmountConvertibleToRewardUnit)
                prizes = try container.decode([Prize].self, forKey: .prizes)
            } catch {
                WayAppUtils.Log.message("Missing paymentAmountConvertibleToRewardUnit or prizes")
            }

        }
        
        override func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            do {
                try container.encode(paymentAmountConvertibleToRewardUnit, forKey: .paymentAmountConvertibleToRewardUnit)
                try container.encode(prizes, forKey: .prizes)
                try super.encode(to: encoder)
            } catch {
                WayAppUtils.Log.message("Missing paymentAmountConvertibleToRewardUnit or prizes")
            }
        }
        
        static func create(_ campaign: Point, completion: @escaping ([Point]?, Error?) -> Void) {
            WayPay.API.createPointCampaign(campaign).fetch(type: [Point].self) { response in
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

        static func update(_ campaign: Point, completion: @escaping ([Point]?, Error?) -> Void) {
            WayPay.API.updatePointCampaign(campaign).fetch(type: [Point].self) { response in
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
            WayAppUtils.Log.message("CampaignID : \(reward.campaignID), sponsorUUID: \(reward.sponsorUUID)")
            var wonPrizes = [Prize]()
            if let balance = reward.balance,
               let prizes = session.points[reward.campaignID]?.prizes {
                for prize in prizes {
                    WayAppUtils.Log.message("Balance: \(balance), prize.amountToGetIt: \(prize.amountToGetIt)")
                    if prize.amountToGetIt <= balance {
                        wonPrizes.append(prize)
                    }
                }
            }
            return wonPrizes
        }
    }

}

