//
//  Roulette.swift
//  WayPay
//
//  Created by Oscar Anzola on 14/3/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import Foundation

extension WayPay {
    struct Roulette: Hashable, Codable, Identifiable, ContainerProtocol {
        var issuerUUID: String
        var rouletteUUID: String
        var name: String?
        var numberOfElements: Int?
        var colors: [String]?
        var texts: [String]?
        var soundURL: String?
        var centerLogoURL: String?
        var headerLogoURL: String?
        var buttonColor: String?
        var textColor: String?
        var actionText: String?
        var result: Int?
        var resultText: String?
        var creationDate: Date?
        var lastUpdateDate: Date?

        // Protocol Identifiable
        var id: String {
            return rouletteUUID
        }
     
        static func load(customerUUID: String, issuerUUID: String, completion: @escaping ([Roulette]?, Error?) -> Void) {
            WayPay.API.getRoulettes(customerUUID, issuerUUID).fetch(type: [Roulette].self) { response in
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

        static func detail(customerUUID: String, issuerUUID: String, rouletteUUID: String, completion: @escaping ([Roulette]?, Error?) -> Void) {
            WayPay.API.getRoulette(customerUUID, issuerUUID, rouletteUUID).fetch(type: [Roulette].self) { response in
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

        static func spin(customerUUID: String, issuerUUID: String, rouletteUUID: String, spin: Spin, completion: @escaping ([Roulette]?, Error?) -> Void) {
            WayPay.API.rouletteSpin(customerUUID, issuerUUID, rouletteUUID, spin).fetch(type: [Roulette].self) { response in
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

    }
}
