//
//  AfterBanks.swift
//  WayPay
//
//  Created by Oscar Anzola on 17/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//
import Foundation
import AuthenticationServices

extension AfterBanks {
    struct SupportedBank: Codable, Identifiable, ContainerProtocol {
        var service: String // key
        var countryCode: String?
        var swift: String?
        private var fullname: String?
        var image: String?
        var imageSVG: String?
        var paymentsSupported: String?
        
        // Protocol Identifiable
        var id: String {
            return service
        }
        
        func getFullname() -> String {
            return fullname != nil ? fullname! : NSLocalizedString("Missing name", comment: "AfterBanks getFullname")
        }
        
        static func == (lhs: SupportedBank, rhs: SupportedBank) -> Bool {
            return (lhs.service == rhs.service)
        }
        
        static func <(lhs: SupportedBank, rhs: SupportedBank) -> Bool {
            return (lhs.getFullname().uppercased() < rhs.getFullname().uppercased())
        }
        
    } // SupportedBank

    struct GlobalPosition: Codable {
        var product: String?
        var type: String?
        var description: String?
        var iban: String?
        var balance: Double?
        var currency: String?
    }
    
    struct ConsentRequest: Codable {
        var service: String // key
        var validUntil: String // dd-mm-aaaa
        var urlRedirect: String
        var pan: String
    }
    
    struct Consent: Codable, Identifiable, ContainerProtocol {
        var consentId: String
        var token: String
        var globalPosition: [GlobalPosition];
        
        // Protocol Identifiable
        var id: String {
            return consentId
        }
    }
    
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

}

final class AfterBanks: ObservableObject {
    static func getBanks(forCountryCode: String = "ES") {
        Logger.message("******** STARTING getBanks")
        WayPay.API.getBanks(forCountryCode).fetch(type: [SupportedBank].self) { response in
            if case .success(let response?) = response {
                if let banks = response.result {
                    DispatchQueue.main.async {
                        WayPayApp.session.banks.setTo(banks)
                        WayPayApp.session.banks.sort(by: <)
                    }
                } else {
                    WayPay.API.reportError(response)
                }
            } else if case .failure(let error) = response {
                Logger.message(error.localizedDescription)
            }
        }
    }

    /*
    static func getConsentFor(service: String = "sandbox") {
        API.getUserAccountConsent(service).fetch(type: ConsentResponse.self) { response in
            if case .success(let response?) = response {
                Log.message("******** CONSENT=\(response.consentId)")
                Log.message("******** FOLLOW=\(response.follow)")
                DispatchQueue.main.async {
                    //self.bankAuthentication(authURL: response.follow)
                }
            } else if case .failure(let error) = response {
                Log.message(error.localizedDescription)
            }
        }
    }
*/
    static func getConsent(id: String) {
        WayPay.API.getConsentDetail(id).fetch(type: [Consent].self) { response in
            if case .success(let response?) = response {
                if let consents = response.result,
                    let consent = consents.first {
                    Logger.message("******** CONSENT=\(consent)")
                } else {
                    WayPay.API.reportError(response)
                }
            } else if case .failure(let error) = response {
                Logger.message(error.localizedDescription)
            }
        }
    }

    static func getConsent(accountUUID: String, service: String, validUntil: String, pan: String, completion: @escaping (Error?, ConsentResponse?) -> Void) {
        let actualService = OperationEnvironment.current == .staging ? OperationEnvironment.A2A.sandbox : service
        Logger.message("********************** GET CONSENT")
        let consentRequest = ConsentRequest(service: actualService, validUntil: validUntil, urlRedirect: "WAP://pay.wayapp.com", pan: pan)
        
        WayPay.API.getConsent(accountUUID, consentRequest).fetch(type: [ConsentResponse].self) { response in
            if case .success(let response?) = response {
                if let consents = response.result,
                    let consent = consents.first {
                    Logger.message("********************** GET CONSENT=\(consent)")
                    completion(nil, consent)
                } else {
                    Logger.message("********************** GET CONSENT FAILED")
                    completion(WayPay.API.errorFromResponse(response), nil)
                    WayPay.API.reportError(response)
                }
            } else if case .failure(let error) = response {
                completion(error, nil)
                Logger.message(error.localizedDescription)
            }
        }
    }
}
