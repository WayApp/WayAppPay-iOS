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
        var amountToUnit: Int? = 0
        var iAmPoint: Bool = true
        private enum CodingKeys: String, CodingKey {
            case amountToUnit
            case iAmPoint
        }
        
        init(points: Int) {
            self.amountToUnit = points
            let prize: Prize = Prize()
            super.init(name: "Point18", sponsorUUID: "sponsorUUID001", format: .POINT)
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try super.init(from: decoder)
            do {
                amountToUnit = try container.decode(Int.self, forKey: .amountToUnit)
            } catch {
                WayAppUtils.Log.message("CATCH")
                amountToUnit = 0
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

    }

}

