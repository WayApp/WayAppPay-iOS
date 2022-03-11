//
//  Customer.swift
//  WayPay
//
//  Created by Oscar Anzola on 11/3/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import Foundation

extension WayPay {
    
    struct Customer: Codable, ContainerProtocol {
                        
        var customerUUID: String
        var name: String?
        var logo: String?
        var privateKey: String?
        var publicKey: String?
        var registrationCode: String?
        
        var id: String {
            return customerUUID
        }

        static func load(completion: @escaping ([Customer]?, Error?) -> Void) {
            WayPay.API.getCustomers.fetch(type: [Customer].self) { response in
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
