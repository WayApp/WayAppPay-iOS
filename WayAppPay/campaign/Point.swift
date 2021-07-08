//
//  Point.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/7/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    class Point: Campaign {
        var paymentAmountConvertibleToRewardUnit: Int?
        var prizes: [Prize]?
        private enum CodingKeys: String, CodingKey {
            case paymentAmountConvertibleToRewardUnit
            case prizes
        }
        
        init(name: String, description: String = "", sponsorUUID: String, format: Format, expirationDate: Date = Date.distantFuture, state: State = .ACTIVE, paymentAmountConvertibleToRewardUnit: Int) {
            super.init(name: name, description: description, sponsorUUID: sponsorUUID, format: format, expirationDate: expirationDate, state: state)
            self.paymentAmountConvertibleToRewardUnit = paymentAmountConvertibleToRewardUnit
            self.prizes = [Prize(name: "NamePoint1", message: "Message1 win a setence")]
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
            WayAppPay.API.createPointCampaign(campaign).fetch(type: [Point].self) { response in
                switch response {
                case .success(let response?):
                    completion(response.result, nil)
                case .failure(let error):
                    completion(nil, error)
                default:
                    completion(nil, WayAppPay.API.ResponseError.INVALID_SERVER_DATA)
                }
            }
        }

        static func update(_ campaign: Point, completion: @escaping ([Point]?, Error?) -> Void) {
            WayAppPay.API.updatePointCampaign(campaign).fetch(type: [Point].self) { response in
                switch response {
                case .success(let response?):
                    completion(response.result, nil)
                case .failure(let error):
                    completion(nil, error)
                default:
                    completion(nil, WayAppPay.API.ResponseError.INVALID_SERVER_DATA)
                }
            }
        }

    }

}

