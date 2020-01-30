//
//  API.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import UIKit

extension WayAppPay {
    
    enum API: HTTPCallEndpoint {
        static var jsonEncoder: JSONEncoder {
            return WayAppPay.jsonEncoder
        }
        
        static var jsonDecoder: JSONDecoder {
            return WayAppPay.jsonDecoder
        }
        
        typealias Email = String
        typealias PIN = String

        enum Result<T, U> where U: Swift.Error {
            case success(T?)
            case failure(U)
        }
        
        private struct Response<T: Decodable>: Decodable {
            let input: String?
            let result: T?
        }
        // Product
        case getProducts(String) // GET
        case getOffersWithLocation(String, Double, Double) // GET
        case createVoucher(String, String) // POST
        case favourOffer(String) // POST
        case unfavourOffer(String) // DELETE
        case getOfferReviews(String) // GET
        // Merchants
        case getMerchants // GET
        case getMerchantsWithLocation(Double, Double) // GET
        // Events
        case getEvents // GET
        case getEventsWithLocation(Double, Double) // GET
        case getEventTickets // GET
        case createEventTicket(String) // POST
        case getFavoredEvents // GET
        case favourEvent(String) // POST
        case unfavourEvent(String) // DELETE
        // Loyalty
        case getLoyaltyCards // GET
        case getLoyaltyCard(String) // GET
        case createLoyaltyCard(String) // POST
        case getLoyaltyPrograms // GET
        case disableLoyaltyCard(String) // PATCH
        // Account
        case deleteAccount(String) // DELETE
        case deleteAccountImage(String) // DELETE
        case getAccount // GET
        case account(WayAppPay.Account) // POST
        case editAccount(WayAppPay.Account, UIImage?) // PATCH
        case terms // POST
        case changePassword(PIN, PIN) // PATCH
        case forgotPassword(Email) // POST
        case registrationOTP(Email) // POST
        case registration(Email, PIN) // POST
        case markNotificationRead(String) // PATCH

        private var path: String {
            switch self {
            // Products
            case .getProducts(let accountUUID): return "/accounts/\(accountUUID)/offers/"
            case .getOffersWithLocation(let accountUUID, let latitude, let longitude): return "/accounts/\(accountUUID)/offers?latitude=\(latitude)&longitude=\(longitude)"
            case .createVoucher(let accountUUID, let uuid): return "/accounts/\(accountUUID)/offers/\(uuid)/vouchers/"
            case .favourOffer(let uuid), .unfavourOffer(let uuid):
                return "/accounts/\(WayAppPay.Session.accountUUID)/offers/\(uuid)/favorites/"
            case .getOfferReviews(let id): return "/accounts/\(WayAppPay.Session.accountUUID)/offers/\(id)/reviews"
            // Merchants
            case .getMerchants: return "/accounts/\(WayAppPay.Session.accountUUID)/merchants/"
            case .getMerchantsWithLocation(let latitude, let longitude): return "/accounts/\(WayAppPay.Session.accountUUID)/merchants?latitude=\(latitude)&longitude=\(longitude)"
                // Events
            case .getEvents: return "/accounts/\(WayAppPay.Session.accountUUID)/events/"
            case .getEventsWithLocation(let latitude, let longitude): return "/accounts/\(WayAppPay.Session.accountUUID)/events?latitude=\(latitude)&longitude=\(longitude)"
            case .getEventTickets: return "/accounts/\(WayAppPay.Session.accountUUID)/events/tickets"
            case .createEventTicket(let uuid): return "/accounts/\(WayAppPay.Session.accountUUID)/events/\(uuid)/tickets/"
            case .getFavoredEvents: return "/accounts/\(WayAppPay.Session.accountUUID)/events/favorites"
            case .favourEvent(let uuid), .unfavourEvent(let uuid):
                return "/accounts/\(WayAppPay.Session.accountUUID)/events/\(uuid)/favorites/"
            case .getLoyaltyPrograms: return "/accounts/\(WayAppPay.Session.accountUUID)/loyalties?status=ENABLED"
            case .getLoyaltyCards: return "/accounts/\(WayAppPay.Session.accountUUID)/loyalties/cards/"
            case .getLoyaltyCard(let id): return "/accounts/\(WayAppPay.Session.accountUUID)/loyalties/cards/\(id)/"
            case .createLoyaltyCard(let id): return "/accounts/\(WayAppPay.Session.accountUUID)/merchants/\(id)/loyalties/cards/"
            
            case .disableLoyaltyCard(let id): return "/accounts/\(WayAppPay.Session.accountUUID)/loyalties/cards/\(id)/disables/"
            case .account, .getAccount: return "/accounts/"
            case .deleteAccount(let uuid): return "/accounts/\(uuid)/"
            case .deleteAccountImage(let uuid): return "/accounts/\(uuid)/images/"
            case .editAccount: return "/accounts/\(WayAppPay.Session.accountUUID)/"
            case .terms: return "/accounts/\(WayAppPay.Session.accountUUID)/terms/"
            case .changePassword: return "/accounts/\(WayAppPay.Session.accountUUID)/passwords/"
            case .forgotPassword: return "/accounts/forgots/"
            case .registrationOTP: return "/accounts/registrations/otp/"
            case .registration: return "/accounts/registrations/"
            case .markNotificationRead: return "/accounts/\(Session.accountUUID)/notifications/"
            }
        }
        
                static func checkForNetworkError(_ error: HTTPCall.Error, view: UIViewController) {
                    DispatchQueue.main.async {
                        if error == .noNetwork {
                            let oopsVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "OopsVC")
                            view.present(oopsVC, animated: true, completion: nil)
                        } else {
                            Log.message(error.localizedDescription)
                        }
                    }
                }
                
                static func checkNetwokAndDisplayOops(from view: UIViewController) {
                    if !HTTPCall.isNetworkReachable() {
                        let oopsVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "OopsVC")
                        view.present(oopsVC, animated: true, completion: nil)
                    }
                }

                private func httpCall<T: Decodable>(type decodingType: T.Type, completionHandler completion: @escaping (Result<T, HTTPCall.Error>) -> Void) {
                    switch self {
                    case .getProducts,.getOfferReviews, .getMerchants,.getEvents, .getAccount, .getLoyaltyPrograms, .getLoyaltyCards, .getLoyaltyCard, .getEventTickets, .getFavoredEvents, .getOffersWithLocation, .getMerchantsWithLocation,.getEventsWithLocation:
                        HTTPCall.GET(self).task(type: Response<T>.self) { response, error in
                            if let error = error {
                                completion(.failure(error))
                            } else if let response = response as? Response<T> {
                                completion(.success(response.result))
                            }
                        }
                    case .createVoucher, .registrationOTP, .registration, .account, .createLoyaltyCard, .createEventTicket, .terms:
                        // Response with data
                        HTTPCall.POST(self).task(type: Response<T>.self) { response, error in
                            if let error = error {
                                completion(.failure(error))
                            } else if let response = response as? Response<T> {
                                completion(.success(response.result))
                            }
                        }
                    case .favourOffer, .favourEvent, .forgotPassword:
                        // Response with no data
                        HTTPCall.POST(self).task(type: Response<T>.self) { response, error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(nil))
                            }
                        }
                    
                    case .editAccount, .changePassword, .disableLoyaltyCard:
                        // Response with data
                        HTTPCall.PATCH(self).task(type: Response<T>.self) { response, error in
                            if let error = error {
                                completion(.failure(error))
                            } else if let response = response as? Response<T> {
                                completion(.success(response.result))
                            }
                        }
                    case .markNotificationRead:
                        // Response with no data
                        HTTPCall.PATCH(self).task(type: Response<T>.self) { response, error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(nil))
                            }
                        }
                    case .deleteAccountImage:
                        // Response with data
                        HTTPCall.DELETE(self).task(type: Response<T>.self) { response, error in
                            if let error = error {
                                completion(.failure(error))
                            } else if let response = response as? Response<T> {
                                completion(.success(response.result))
                            }
                        }
                    case .unfavourOffer, .unfavourEvent, .deleteAccount:
                        // Response with no data
                        HTTPCall.DELETE(self).task(type: Response<T>.self) { response, error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(nil))
                            }
                        }
                    }
                }
                
                func fetch<T: Decodable>(type decodingType: T.Type, completionHandler completion: @escaping (Result<T, HTTPCall.Error>) -> Void) {
                    switch self {
                    case .registrationOTP, .registration, .forgotPassword:
                        httpCall(type: decodingType, completionHandler: completion)
                    default:
        //                guard let token = WayAppPay.Session.token else {
        //                    Log.message("Missing WayAppPay.Session.token")
        //                    return
        //                }
                        return
        //                token.getValidToken() { token in
        //                    if token != nil {
        //                        self.httpCall(type: decodingType, completionHandler: completion)
        //                    } else {
        //                        DispatchQueue.main.async {
        //                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppDelegate.logoutRequest), object: nil, userInfo: nil)
        //                        }
        //                    }
        //                }
                    }
                }

                var url: URL? {
                    return URL(string: environment.alavueltaAPIBaseURL + path)
                }
                
                var body: (String, Data)? {
                    switch self {
                    case .account(let account):
                        if let part = HTTPCall.BodyPart(account, name: "account") {
                            return (part.contentType, part.data)
                        }
                        return nil
                    case .editAccount(let account, let picture):
                        var parts: [HTTPCall.BodyPart]?
                        if let part = HTTPCall.BodyPart(account, name: "account") {
                            parts = [part]
                            if let picture = picture {
                                parts?.append(HTTPCall.BodyPart.image(name: "photo", image: picture))
                            }
                        }
                        if let parts = parts {
                            let multipart = HTTPCall.BodyPart.multipart(parts)
                            return (multipart.contentType, multipart.data)
                        }
                        return nil
                    case .registration(let email, let pin):
                        let dictionary = ["email": email, "pin": pin] as JSON
                        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: []) {
                            let part = HTTPCall.BodyPart.data(name: "registration", data: jsonData)
                            return (part.contentType, part.data)
                        }
                        return nil
                    case .changePassword(let old, let new):
                        let dictionary = ["oldPin": old, "newPin": new] as JSON
                        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: []) {
                            let part = HTTPCall.BodyPart.data(name: "registration", data: jsonData)
                            return (part.contentType, part.data)
                        }
                        return nil
                    case .forgotPassword(let email):
                        let dictionary = ["email": email] as JSON
                        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary) {
                            let part = HTTPCall.BodyPart.data(name: "pin", data: jsonData)
                            return (part.contentType, part.data)
                        }
                        return nil
                    case .terms:
                        let dictionary = ["terms": WayAppPay.termsAndConditions] as JSON
                        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary) {
                            let part = HTTPCall.BodyPart.data(name: "terms", data: jsonData)
                            return (part.contentType, part.data)
                        }
                        return nil
                    case .markNotificationRead(let id):
                        let dictionary = ["notificationID": id] as JSON
                        if let jsonData = try? JSONSerialization.data(withJSONObject: [dictionary], options: []) {
                            let part = HTTPCall.BodyPart.data(name: "notification", data: jsonData)
                            return (part.contentType, part.data)
                        }
                        return nil

                    default:
                        return nil
                    }
                }
                
                var headers: [String: String]? {
                    switch self {
                    case .registrationOTP, .registration, .forgotPassword:
                        return ["AuthKey": environment.abancaOauthAuthKey]
                    default:
        //                if let token = WayAppPay.Session.token?.token {
        //                    return ["AuthKey": environment.abancaOauthAuthKey,
        //                            "Authorization": "Bearer " + token]
        //                }
                        return nil
                    }
                }
                
                func isUnauthorizedStatusCode(_ code: Int) -> Bool {
                    if code == 401 || code == 403 {
                        DispatchQueue.main.async {
        //                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppDelegate.logoutRequest), object: nil, userInfo: nil)
                        }
                        return true
                    }
                    return false
                }


    }
}
