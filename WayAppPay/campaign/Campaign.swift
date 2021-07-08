//
//  Campaign.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/5/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    
    struct Prize: Hashable, Codable {
        enum Format: String, Codable {
            case CASHBACK, COUPON, MANUAL
        }
        var name: String?
        var message: String
        var threshold: Int
        var value: Int?
        var format: Format?
        
        init(name: String, message: String) {
            self.message = message
            self.name = name
            self.format = .MANUAL
            self.threshold = 0
        }
    }

    struct Reward: Hashable, Codable {
        var accountUUID: String?
        var campaignID: String?
        var sponsorUUID: String?
        var creationDate: Date?
        var lastUpdateDate: Date?
        var lastTransactionUUID: String?
        var balance: Int?
    }
    
    class Campaign: Hashable, Codable, Identifiable, Equatable, ContainerProtocol {
        
        static func == (lhs: WayAppPay.Campaign, rhs: WayAppPay.Campaign) -> Bool {
            return (lhs.id == rhs.id) && (lhs.sponsorUUID == rhs.sponsorUUID)
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
        }

        var sponsorUUID: String
        var id: String
        var name: String
        var format: Format
        var description: String?
        var state: State?
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
        
        static func get<T: Campaign>(merchantUUID: String, issuerUUID: String?, campaignType: T.Type, format: Format, completion: @escaping ([T]?, Error?) -> Void) {
            WayAppPay.API.getCampaigns(merchantUUID, issuerUUID, format).fetch(type: [T].self) { response in
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

        static func get(campaignID: String, sponsorUUID: String, format: Format, completion: @escaping ([Campaign]?, Error?) -> Void) {
            WayAppPay.API.getCampaign(campaignID, sponsorUUID, format).fetch(type: [Campaign].self) { response in
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

        static func reward(transaction: PaymentTransaction, campaignIDs: Array<String>, completion: @escaping ([Campaign]?, Error?) -> Void) {
            WayAppPay.API.rewardCampaigns(transaction, campaignIDs).fetch(type: [Campaign].self) { response in
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

        static func redeem(transaction: PaymentTransaction, campaignIDs: Array<String>, completion: @escaping ([Campaign]?, Error?) -> Void) {
            WayAppPay.API.redeemCampaigns(transaction, campaignIDs).fetch(type: [Campaign].self) { response in
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

        func toggleState(completion: @escaping ([Campaign]?, Error?) -> Void) {
            WayAppPay.API.toggleCampaignState(self.id, self.sponsorUUID, self.format).fetch(type: [Campaign].self) { response in
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
        
        static func delete(id: String, sponsorUUID: String, format: Format, completion: @escaping ([String]?, Error?) -> Void) {
            WayAppPay.API.deleteCampaign(id, sponsorUUID, format).fetch(type: [String].self) { response in
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
