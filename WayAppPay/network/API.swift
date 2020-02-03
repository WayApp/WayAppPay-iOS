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

        enum Result<T: Decodable, U> where U: Swift.Error {
            case success(Response<T>?)
            case failure(U)
        }
        
        static func reportError<T: Decodable>(_ response: Response<T>) {
            WayAppUtils.Log.message("Code=\(response.code ?? 0) , Status=\(response.status ?? "no status"), moreInfo=\(response.moreInfo ?? "no more info")")
        }
        
        struct Response<T: Decodable>: Decodable {
            let input: String?
            let description: String?
            let code: Int?
            let status: String?
            let links: String?
            let moreInfo: String?
            let moreInfoCode: String?
            let result: T?
        }
        
        // Account
        case getAccount(Email, PIN) // GET
        case getMerchants(String) // GET
        case getProducts(String) // GET
        case addProduct(String, WayAppPay.Product, UIImage?) // POST
        case updateProduct(String, WayAppPay.Product, UIImage?) // PATCH
        case deleteProduct(String, String) // DELETE

        case deleteAccount(String) // DELETE
        case account(WayAppPay.Account) // POST
        case editAccount(WayAppPay.Account, UIImage?) // PATCH
        case changePassword(PIN, PIN) // PATCH
        case forgotPassword(Email) // POST
        case registrationOTP(Email) // POST
        case registration(Email, PIN) // POST
        case markNotificationRead(String) // PATCH

        // Product
        case createVoucher(String, String) // POST
        case createEventTicket(String) // POST
        // Loyalty
        case createLoyaltyCard(String) // POST
        case disableLoyaltyCard(String) // PATCH

        private func hashedPIN(_ pin: String) -> String {
            let escapedPIN = pin.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
            return escapedPIN.sha1()
        }
        private var path: String {
            switch self {
            // Products
            case .getAccount(let email, let pin): return "/accounts/\(email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)/\(hashedPIN(pin))/"
            case .getMerchants(let accountUUID): return "/accounts/\(accountUUID)/merchants/"
            case .getProducts(let merchantUUID): return "/merchants/\(merchantUUID)/products/"
            case .addProduct(let merchantUUID, _, _): return "/merchants/\(merchantUUID)/products/"
            case .updateProduct(let merchantUUID, let product, _): return "/merchants/\(merchantUUID)/products/\(product.productUUID)/"
            case .deleteProduct(let merchantUUID, let productUUID): return "/merchants/\(merchantUUID)/products/\(productUUID)/"
                
            case .createVoucher(let accountUUID, let uuid): return "/accounts/\(accountUUID)/offers/\(uuid)/vouchers/"
            case .createEventTicket(let uuid): return "/accounts/\(WayAppPay.Session.accountUUID!)/events/\(uuid)/tickets/"
            case .createLoyaltyCard(let id): return "/accounts/\(WayAppPay.Session.accountUUID!)/merchants/\(id)/loyalties/cards/"
            
            case .disableLoyaltyCard(let id): return "/accounts/\(WayAppPay.Session.accountUUID!)/loyalties/cards/\(id)/disables/"
            case .account: return "/accounts/"
            case .deleteAccount(let uuid): return "/accounts/\(uuid)/"
            case .editAccount: return "/accounts/\(WayAppPay.Session.accountUUID!)/"
            case .changePassword: return "/accounts/\(WayAppPay.Session.accountUUID!)/passwords/"
            case .forgotPassword: return "/accounts/forgots/"
            case .registrationOTP: return "/accounts/registrations/otp/"
            case .registration: return "/accounts/registrations/"
            case .markNotificationRead: return "/accounts/\(Session.accountUUID!)/notifications/"
            }
        }
        
        private var signature: String {
            switch self {
            // Products
            case .getAccount(let email, let pin): return email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)! + "/" + hashedPIN(pin)
            case .getMerchants(let accountUUID): return accountUUID
            case .getProducts(let merchantUUID): return merchantUUID
            case .addProduct(let merchantUUID, _, _): return merchantUUID
            case .deleteProduct(let merchantUUID, let productUUID): return merchantUUID + "/" + productUUID
            case .updateProduct(let merchantUUID, let product, _): return merchantUUID + "/" + product.productUUID
            default:
                return ""
            }
        }
        static func checkForNetworkError(_ error: HTTPCall.Error, view: UIViewController) {
            DispatchQueue.main.async {
                if error == .noNetwork {
                    let oopsVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "OopsVC")
                    view.present(oopsVC, animated: true, completion: nil)
                } else {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }
        
        static func checkNetwokAndDisplayOops(from view: UIViewController) {
            if !HTTPCall.isNetworkReachable() {
                let oopsVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "OopsVC")
                view.present(oopsVC, animated: true, completion: nil)
            }
        }
        
        func fetch<T: Decodable>(type decodingType: T.Type, completionHandler result: @escaping (Result<T, HTTPCall.Error>) -> Void) {
            httpCall(type: decodingType, completionHandler: result)
        }
        

        private func httpCall<T: Decodable>(type decodingType: T.Type, completionHandler result: @escaping (Result<T, HTTPCall.Error>) -> Void) {
            switch self {
            case .getAccount, .getProducts, .getMerchants:
                HTTPCall.GET(self).task(type: Response<T>.self) { response, error in
                    if let error = error {
                        result(.failure(error))
                    } else if let response = response as? Response<T> {
                        result(.success(response))
                    }
                }
            case .addProduct, .createVoucher, .registrationOTP, .registration, .account, .createLoyaltyCard, .createEventTicket:
                // Response with data
                HTTPCall.POST(self).task(type: Response<T>.self) { response, error in
                    if let error = error {
                        result(.failure(error))
                    } else if let response = response as? Response<T> {
                        result(.success(response))
                    }
                }
            case .forgotPassword:
                // Response with no data
                HTTPCall.POST(self).task(type: Response<T>.self) { response, error in
                    if let error = error {
                        result(.failure(error))
                    } else {
                        result(.success(nil))
                    }
                }
                
            case .updateProduct, .editAccount, .changePassword, .disableLoyaltyCard:
                // Response with data
                HTTPCall.PATCH(self).task(type: Response<T>.self) { response, error in
                    if let error = error {
                        result(.failure(error))
                    } else if let response = response as? Response<T> {
                        result(.success(response))
                    }
                }
            case .markNotificationRead:
                // Response with no data
                HTTPCall.PATCH(self).task(type: Response<T>.self) { response, error in
                    if let error = error {
                        result(.failure(error))
                    } else {
                        result(.success(nil))
                    }
                }
            case .deleteProduct:
                // Response with data
                HTTPCall.DELETE(self).task(type: Response<T>.self) { response, error in
                    if let error = error {
                        result(.failure(error))
                    } else if let response = response as? Response<T> {
                        result(.success(response))
                    }
                }
            case .deleteAccount:
                // Response with no data
                HTTPCall.DELETE(self).task(type: Response<T>.self) { response, error in
                    if let error = error {
                        result(.failure(error))
                    } else {
                        result(.success(nil))
                    }
                }
            }
        }

        var url: URL? {
            let timestamp = Date().timeIntervalSince1970
            let signatureTimestamped = signature.appending("/" + String(timestamp))
            let baseURL = environment.wayappPayAPIBaseURL + path + String(timestamp) + "/"
            return URL(string: baseURL + environment.wayAppPayPublicKey + "/" + signatureTimestamped.digest(algorithm: .SHA256, key: environment.wayAppPayPrivateKey))
        }
        
        var body: (String, Data)? {
            switch self {
            case .account(let account):
                if let part = HTTPCall.BodyPart(account, name: "account") {
                    return (part.contentType, part.data)
                }
                return nil
            case .addProduct(_, let product, let picture):
                var parts: [HTTPCall.BodyPart]?
                if let part = HTTPCall.BodyPart(product, name: "product") {
                    parts = [part]
                    if let picture = picture {
                        parts?.append(HTTPCall.BodyPart.image(name: "picture", image: picture))
                    }
                }
                if let parts = parts {
                    let multipart = HTTPCall.BodyPart.multipart(parts)
                    return (multipart.contentType, multipart.data)
                }
                return nil
            case .updateProduct(_, let product, let picture):
                var parts: [HTTPCall.BodyPart]?
                if let part = HTTPCall.BodyPart(product, name: "product") {
                    parts = [part]
                    if let picture = picture {
                        parts?.append(HTTPCall.BodyPart.image(name: "picture", image: picture))
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
            return nil
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
