//
//  AfterBanks.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 06/09/2020.
//  Copyright © 2020 WayApp. All rights reserved.
//

import Foundation
import AuthenticationServices

final class AfterBanks: ObservableObject {
    @Published var banks = Container<SupportedBank>()
    var follow: String?
    var consentId: String?
    
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

        var containerID: String {
            return service
        }
        
        init(countryCode: String = "ES", paymentsSupported: String = "1") {
            self.service = UUID().uuidString
            self.countryCode = countryCode
            self.paymentsSupported = paymentsSupported
        }
    } // SupportedBank
    
    func getBanks(forCountryCode: String = "ES") {
        WayAppUtils.Log.message("******** STARTING getBanks")
        WayAppPay.API.getBanks(forCountryCode).fetch(type: [[SupportedBank]].self) { response in
            if case .success(let response?) = response {
                if let banks = response.result?.first {
                    WayAppUtils.Log.message("******** BANKS=\(banks)")
                    DispatchQueue.main.async {
                        self.banks.setTo(banks)
                    }
                } else {
                    WayAppPay.API.reportError(response)
                }
            } else if case .failure(let error) = response {
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }
    }

    func getConsentFor(service: String = "sandbox") {
        API.getUserAccountConsent(service).fetch(type: ConsentResponse.self) { response in
            if case .success(let response?) = response {
                WayAppUtils.Log.message("******** CONSENT=\(response.consentId)")
                WayAppUtils.Log.message("******** FOLLOW=\(response.follow)")
                self.follow = response.follow
                self.consentId = response.consentId
                DispatchQueue.main.async {
                    //self.bankAuthentication(authURL: response.follow)
                }
            } else if case .failure(let error) = response {
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }
    }

    func getConsent(id: String) {
        WayAppPay.API.getConsentDetail(id).fetch(type: [Consent].self) { response in
            if case .success(let response?) = response {
                if let consents = response.result,
                    let consent = consents.first {
                    WayAppUtils.Log.message("******** CONSENT=\(consent)")
                } else {
                    WayAppPay.API.reportError(response)
                }
            } else if case .failure(let error) = response {
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }
    }

    func getConsent(accountUUID: String, pan: String, service: String, validUntil: String, completion: @escaping (Error?, ConsentResponse?) -> Void) {
        WayAppUtils.Log.message("********************** GET CONSENT")
        let consentRequest = ConsentRequest(service: service, validUntil: validUntil, urlRedirect: "WAP://pay.wayapp.com", pan: pan)
        
        WayAppPay.API.getConsent(accountUUID, consentRequest).fetch(type: [ConsentResponse].self) { response in
            if case .success(let response?) = response {
                if let consents = response.result,
                    let consent = consents.first {
                    WayAppUtils.Log.message("********************** GET CONSENT=\(consent)")
                    completion(nil, consent)
                } else {
                    WayAppUtils.Log.message("********************** GET CONSENT FAILED")
                    completion(WayAppPay.API.errorFromResponse(response), nil)
                    WayAppPay.API.reportError(response)
                }
            } else if case .failure(let error) = response {
                completion(error, nil)
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }
    }


    func initiatePayment(token: String, amount: String, sourceIBAN: String, destinationIBAN: String, destinationCreditorName: String, paymentDescription: String) {
        API.paymentInitiate(token, amount, sourceIBAN, destinationIBAN, destinationCreditorName, paymentDescription).fetch(type: PaymentResponse.self) { response in
            if case .success(let response?) = response {
                WayAppUtils.Log.message("******** CONSENT=\(response.paymentId)")
                WayAppUtils.Log.message("******** FOLLOW=\(response.follow)")
                self.follow = response.follow
                self.consentId = response.paymentId
                DispatchQueue.main.async {
                    //self.bankAuthentication(authURL: response.follow)
                }
            } else if case .failure(let error) = response {
                WayAppUtils.Log.message(error.localizedDescription)
            }
        }
    }

}
