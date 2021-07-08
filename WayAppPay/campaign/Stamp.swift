//
//  Stamp.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/7/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    class Stamp: Campaign {
        var minimumPaymentAmountToGetStamp: Int?
        var prize: Prize?
        private enum CodingKeys: String, CodingKey {
            case minimumPaymentAmountToGetStamp
            case prize
        }

        init(name: String, description: String = "", sponsorUUID: String, format: Format, expirationDate: Date = Date.distantFuture, state: State = .ACTIVE, minimumPaymentAmountToGetStamp: Int) {
            super.init(name: name, description: description, sponsorUUID: sponsorUUID, format: format, expirationDate: expirationDate, state: state)
            self.minimumPaymentAmountToGetStamp = minimumPaymentAmountToGetStamp
            self.prize = Prize(name: "NameStamp1", message: "Message1 for stamp")
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
            WayAppPay.API.createStampCampaign(campaign).fetch(type: [Stamp].self) { response in
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

        static func update(_ campaign: Stamp, completion: @escaping ([Stamp]?, Error?) -> Void) {
            WayAppPay.API.updateStampCampaign(campaign).fetch(type: [Stamp].self) { response in
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
        
        static func delete(at offsets: IndexSet) {
            WayAppUtils.Log.message("Entering")
            for offset in offsets {
                WayAppPay.Campaign.delete(id: session.stamps[offset].id, sponsorUUID: session.stamps[offset].sponsorUUID, format: session.stamps[offset].format) { strings, error in
                    if let error = error {
                        WayAppUtils.Log.message("Campaign: \(session.stamps[offset].name) could not be . Error: \(error.localizedDescription)")
                    } else {
                        WayAppUtils.Log.message("DELETED SUCCESSFULLY")
                        WayAppUtils.Log.message("Campaign: \(session.stamps[offset].name) deleted successfully")
                        DispatchQueue.main.async {
                            WayAppUtils.Log.message("Before total stamps: \(session.stamps.count)")
                            session.stamps.remove(session.stamps[offset])
                            WayAppUtils.Log.message("After total stamps: \(session.stamps.count)")
                        }
                    }
                }
            }
        }

    }
}
