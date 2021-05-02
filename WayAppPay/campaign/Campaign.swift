//
//  Campaign.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/5/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    struct Reward: Hashable, Codable {

        enum Format: String, Codable { //
            case CASHBACK, COUPON
        }
        
        var name: String?
        var message: String?
        var threshold: Int?
        var value: Int?
        var format: Format?
    }
    
    struct Campaign: Hashable, Codable, Identifiable, ContainerProtocol {
        
        enum Format: String, Codable { //
            case STAMP, POINT, CASHBACK
        }

        enum State: String, Codable {
            case ACTIVE, INACTIVE, EXPIRED
        }

        var sponsorUUID: String
        var id: String
        var name: String?
        var description: String?
        var format: Format?
        var status: State?
        var expirationDate: Date?
        var creationDate: Date?
        var lastUpdateDate: Date?
        var threshold: Int?
        var reward: Reward?
        
        var containerID: String {
            return id
        }
        
        init(name: String = "Campaign1", sponsorUUID: String, format: Format) {
            self.name = name
            self.sponsorUUID = sponsorUUID
            self.format = format
            self.id = "1"
        }
        
        static func get(merchantUUID: String, issuerUUID: String, completion: @escaping ([Campaign]?, Error?) -> Void) {
            WayAppPay.API.getCampaigns(merchantUUID, issuerUUID).fetch(type: [Campaign].self) { response in
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

        static func get(campaignID: String, sponsorUUID: String, completion: @escaping ([Campaign]?, Error?) -> Void) {
            WayAppPay.API.getCampaign(campaignID, sponsorUUID).fetch(type: [Campaign].self) { response in
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

        
        static func create(_ campaign: Campaign, completion: @escaping ([Campaign]?, Error?) -> Void) {
            WayAppPay.API.createCampaign(campaign).fetch(type: [Campaign].self) { response in
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
