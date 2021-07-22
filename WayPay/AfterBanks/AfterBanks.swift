//
//  AfterBanks.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 24/2/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import Foundation
import AuthenticationServices

final class AfterBanks: ObservableObject {
    
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }
    
    struct ConsentResponse: Codable {
        var follow: String
        var consentId: String
    } // ConsentResponse
    
    struct PaymentResponse: Codable {
        var follow: String
        var paymentId: String
    } // PaymentResponse
    
    struct SupportedBank: Codable, Identifiable, ContainerProtocol {
        var service: String // key
        var countryCode: String?
        var swift: String?
        var fullname: String?
        var image: String?
        var imageSVG: String?
        var paymentsSupported: String?
        
        // Protocol Identifiable
        var id: String {
            return service
        }
        
        init(countryCode: String = "ES", paymentsSupported: String = "1") {
            self.service = UUID().uuidString
            self.countryCode = countryCode
            self.paymentsSupported = paymentsSupported
        }
    } // SupportedBank
    
    static func getBanks(forCountryCode: String = "ES") {
        WayAppUtils.Log.message("******** STARTING getBanks")
        WayPay.API.getBanks(forCountryCode).fetch(type: [[SupportedBank]].self) { response in
            if case .success(let response?) = response {
                if let banks = response.result?.first {
                    WayAppUtils.Log.message("******** BANKS=\(banks)")
                    DispatchQueue.main.async {
                        WayPay.session.banks.setTo(banks)
                    }
                } else {
                    WayPay.API.reportError(response)
                }
            } else if case .failure(let error) = response {
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }
    }

    /*
    static func getConsentFor(service: String = "sandbox") {
        API.getUserAccountConsent(service).fetch(type: ConsentResponse.self) { response in
            if case .success(let response?) = response {
                WayAppUtils.Log.message("******** CONSENT=\(response.consentId)")
                WayAppUtils.Log.message("******** FOLLOW=\(response.follow)")
                DispatchQueue.main.async {
                    //self.bankAuthentication(authURL: response.follow)
                }
            } else if case .failure(let error) = response {
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }
    }
*/
    static func getConsent(id: String) {
        WayPay.API.getConsentDetail(id).fetch(type: [Consent].self) { response in
            if case .success(let response?) = response {
                if let consents = response.result,
                    let consent = consents.first {
                    WayAppUtils.Log.message("******** CONSENT=\(consent)")
                } else {
                    WayPay.API.reportError(response)
                }
            } else if case .failure(let error) = response {
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }
    }

    static func getConsent(accountUUID: String, service: String, validUntil: String, pan: String, completion: @escaping (Error?, ConsentResponse?) -> Void) {
        let actualService = OperationalEnvironment.current == .staging ? "sandbox" : service
        WayAppUtils.Log.message("********************** GET CONSENT")
        let consentRequest = ConsentRequest(service: actualService, validUntil: validUntil, urlRedirect: "WAP://pay.wayapp.com", pan: pan)
        
        WayPay.API.getConsent(accountUUID, consentRequest).fetch(type: [ConsentResponse].self) { response in
            if case .success(let response?) = response {
                if let consents = response.result,
                    let consent = consents.first {
                    WayAppUtils.Log.message("********************** GET CONSENT=\(consent)")
                    completion(nil, consent)
                } else {
                    WayAppUtils.Log.message("********************** GET CONSENT FAILED")
                    completion(WayPay.API.errorFromResponse(response), nil)
                    WayPay.API.reportError(response)
                }
            } else if case .failure(let error) = response {
                completion(error, nil)
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }
    }

/*
    func initiatePayment(token: String, amount: String, sourceIBAN: String, destinationIBAN: String, destinationCreditorName: String, paymentDescription: String) {
        API.paymentInitiate(token, amount, sourceIBAN, destinationIBAN, destinationCreditorName, paymentDescription).fetch(type: PaymentResponse.self) { response in
            if case .success(let response?) = response {
                WayAppUtils.Log.message("******** CONSENT=\(response.paymentId)")
                WayAppUtils.Log.message("******** FOLLOW=\(response.follow)")
                DispatchQueue.main.async {
                    //self.bankAuthentication(authURL: response.follow)
                }
            } else if case .failure(let error) = response {
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }
    }
*/
}
