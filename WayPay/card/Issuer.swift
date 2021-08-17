//
//  Issuer.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

extension WayPay {
    
    struct Issuer: Hashable, Codable, Identifiable, ContainerProtocol {
        var issuerUUID: String
        var foregroundColor: String?
        var labelColor: String?
        var backgroundColor: String?
        var passTypeIdentifier: String?
        var certApple: String?
        var aliasCertApple: String?
        var certPassword: String?
        var name: String?
        var description: String?
        var iconURL: String?
        var logoURL: String?
        var stripURL: String?
        var creationDate: Date?
        var lastUpdateDate: Date?
        
        // Protocol Identifiable
        var id: String {
            return issuerUUID
        }
                
        static func expireCards(issuerUUID: String, completion: @escaping ([Issuer]?, Error?) -> Void) {
            WayPay.API.expireIssuerCards(issuerUUID).fetch(type: [Issuer].self) { response in
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

        
        static func getTransactions(issuerUUID: String, initialDate: String, finalDate: String, completion: @escaping ([PaymentTransaction]?, Error?) -> Void) {
            WayPay.API.getIssuerTransactions(issuerUUID,initialDate, finalDate)
                .fetch(type: [PaymentTransaction].self) { response in
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
