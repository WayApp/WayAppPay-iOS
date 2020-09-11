//
//  AfterBanksAPI.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 06/09/2020.
//  Copyright © 2020 WayApp. All rights reserved.
//

import Foundation

extension AfterBanks {
    /*
     * Process to add any API method:
     * 1) Add the case to the API enum
     * 2) Add the path
     * 3) Add signature
     * 4) Add it to the switch on httpCall (GET, PATCH ...)
     * 5) Only if it PATCH, PUT or POST add the body
     */
    enum API: HTTPCallEndpoint {
        static var jsonEncoder: JSONEncoder {
            return WayAppPay.jsonEncoder
        }
        
        static var jsonDecoder: JSONDecoder {
            return WayAppPay.jsonDecoder
        }
        
        typealias Email = String
        typealias PIN = String
        typealias Day = String

        enum Result<T: Decodable, U> where U: Swift.Error {
            case success(T?)
            case failure(U)
        }
        
        case listOfSupportedBanks(String)
        case getUserAccountConsent(String)
        case paymentInitiate(String, String, String, String, String, String)

        private var path: String {
            switch self {
            case .listOfSupportedBanks(let countryCode): return "/listOfSupportedBanks//?countryCode=\(countryCode)"
            case .getUserAccountConsent: return "/consent/get/"
            case .paymentInitiate: return "/payment/initiate/"
            }
        }
                
        func fetch<T: Decodable>(type decodingType: T.Type, completionHandler result: @escaping (Result<T, HTTPCall.Error>) -> Void) {
            // Need this function for future support of distinct APIs
            httpCall(type: decodingType, completionHandler: result)
        }
        

        private func httpCall<T: Decodable>(type decodingType: T.Type, completionHandler result: @escaping (Result<T, HTTPCall.Error>) -> Void) {
            switch self {
            case .listOfSupportedBanks:
                HTTPCall.GET(self).task(type: T.self) { response, error in
                    if let error = error {
                        result(.failure(error))
                    } else if let response = response as? T {
                        result(.success(response))
                    }
                }
            case .getUserAccountConsent, .paymentInitiate:
                HTTPCall.POST(self).task(type: T.self) { response, error in
                    if let error = error {
                        result(.failure(error))
                    } else if let response = response as? T {
                        result(.success(response))
                    }
                }
            }
        }

        var url: URL? {
            let baseURL = OperationalEnvironment.afterBanksBaseURL + path
            return URL(string: baseURL)
        }
               
        private func postItems(_ parameters: [(String, String)]) -> String {
             var string = String()
             var separator = ""
             
             for (key, value) in parameters {
                 string += separator + key + "=" + value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                 separator = "&"
             }
             return string
         }

        var body: (String, Data)? {
            switch self {
            case .getUserAccountConsent(let service):
                // Does not use Dictionary to allow repeated keys
                 var parameters = [(String, String)]()
                 parameters.append(("servicekey", OperationalEnvironment.afterBanksServiceKey))
                 parameters.append(("service", service))
                 parameters.append(("grantType", "payment"))
                 parameters.append(("validUntil", "30-09-2020"))
                 parameters.append(("yourConsentCallback", OperationalEnvironment.afterBanksConsentCallback))
                 parameters.append(("urlRedirect", "WAP://pay.wayapp.com"))
                 let string = postItems(parameters)
                 return ("application/x-www-form-urlencoded", string.data(using: .utf8)!)
            case .paymentInitiate(let token, let amount, let sourceIBAN, let destinationIBAN, let destinationCreditorName, let paymentDescription):
                // Does not use Dictionary to allow repeated keys
                 var parameters = [(String, String)]()
                 parameters.append(("servicekey", OperationalEnvironment.afterBanksServiceKey))
                 parameters.append(("token", token))
                 parameters.append(("paymentType", "normal"))
                 parameters.append(("currency", "EUR"))
                 parameters.append(("amount", amount))
                 parameters.append(("yourPaymentCallback", OperationalEnvironment.afterBanksPaymentCallback))
                 parameters.append(("urlRedirect", "WAP://pay.wayapp.com"))
                 parameters.append(("sourceIBAN", sourceIBAN))
                 parameters.append(("destinationIBAN", destinationIBAN))
                 parameters.append(("destinationCreditorName", destinationCreditorName))
                 parameters.append(("paymentDescription", paymentDescription))
                 parameters.append(("urlRedirect", "WAP://pay.wayapp.com"))
                 let string = postItems(parameters)
                 return ("application/x-www-form-urlencoded", string.data(using: .utf8)!)
            default:
                return nil
            }
        }
        
        var headers: [String: String]? {
            // Here for potential future support of methods that require header
            return nil
        }
        
        func isUnauthorizedStatusCode(_ code: Int) -> Bool {
            if code == 401 || code == 403 {
                DispatchQueue.main.async {
                    // FIXME
                    // NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppDelegate.logoutRequest), object: nil, userInfo: nil)
                }
                return true
            }
            return false
        }
    }
}
