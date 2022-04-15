//
//  Issuer.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation
import UIKit

extension WayPay {
    
    struct Issuer: Hashable, Codable, Identifiable, ContainerProtocol {
        static let defaultIcon = "AppIcon"
        static let defaultLogo = "logoPlaceholder"
        static let defaultStrip = "WayPay-Logo"

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
        var issuedPaymentTokens: Int?
        var maxPaymentTokens: Int?
        var customerUUID: String?

        init(customerUUID: String, name: String, description: String, labelColor: String, backgroundColor: String, foregroundColor: String) {
            self.issuerUUID = UUID().uuidString
            self.customerUUID = customerUUID
            self.name = name
            self.description = description
            self.labelColor = labelColor
            self.backgroundColor = backgroundColor
            self.foregroundColor = foregroundColor
            self.passTypeIdentifier = "pass.com.wayapp.pay"
            self.aliasCertApple = "WayApp Inc"
            self.certPassword = "W4y4ppP4y"
            self.certApple = "AppleWWDRCA.cer"
        }

        // Protocol Identifiable
        var id: String {
            return issuerUUID
        }
                
        static func isColorFormatValid(_ color: String) -> Bool {
            if color.count == 7,
               color.prefix(1) == "#" {
                return true
            }
            return false
        }
        
        static func load(completion: @escaping ([Issuer]?, Error?) -> Void) {
            WayPay.API.getIssuers.fetch(type: [Issuer].self) { response in
                WayPay.API.getIssuers.fetch(type: [Issuer].self) { response in
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
        
        static func delete(_ issuerUUID: String, completion: @escaping (Error?) -> Void) {
            WayPay.API.deleteIssuer(issuerUUID).fetch(type: [String].self) { response in
                switch response {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            }
        }

        static func edit(_ issuer: Issuer, completion: @escaping ([Issuer]?, Error?) -> Void) {
            WayPay.API.editIssuer(issuer).fetch(type: [Issuer].self) { response in
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
        
        static func refresh(issuerUUID: String, completion: @escaping ([Issuer]?, Error?) -> Void) {
            WayPay.API.refreshIssuer(issuerUUID).fetch(type: [Issuer].self) { response in
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
        
        static func create(_ issuer: Issuer, completion: @escaping ([Issuer]?, Error?) -> Void) {
            let icon = UIImage(named: defaultIcon) ?? UIImage()
            let logo = UIImage(named: defaultLogo) ?? UIImage()
            let strip = UIImage(named: defaultStrip) ?? UIImage()
            WayPay.API.createIssuer(issuer, icon, logo, strip).fetch(type: [Issuer].self) { response in
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
