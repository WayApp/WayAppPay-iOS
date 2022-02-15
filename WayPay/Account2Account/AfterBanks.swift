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
    static func getBanks(forCountryCode: String = "ES", completion: @escaping ([SupportedBank]?, Error?) -> Void) {
        WayPay.API.getBanks(forCountryCode).fetch(type: [SupportedBank].self) { response in
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
        WayPay.API.getConsent(id).fetch(type: [Consent].self) { response in
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

    static func getConsent(service: String, validUntil: Date, pan: String, completion: @escaping (ConsentResponse?, Error?) -> Void) {
        let formattedDate: String = AfterBanks.dateFormatter.string(from: validUntil)
        let actualService = OperationEnvironment.current == .staging ? OperationEnvironment.A2A.sandbox : service
        let consentRequest = ConsentRequest(service: actualService, validUntil: formattedDate, urlRedirect: "WAP://thewaypay.com", pan: pan)
        WayPay.API.startConsent(consentRequest).fetch(type: [ConsentResponse].self) { response in
            switch response {
            case .success(let response?):
                completion(response.result?.first, nil)
            case .failure(let error):
                completion(nil, error)
            default:
                completion(nil, WayPay.API.ResponseError.INVALID_SERVER_DATA)
            }
        }
    }
}
