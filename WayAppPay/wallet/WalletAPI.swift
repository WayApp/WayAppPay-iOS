//
//  API.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import UIKit

extension WayAppPay {
    /*
     * Process to add any API method:
     * 1) Add the case to the API enum
     * 2) Add the path
     * 3) Add signature
     * 4) Add it to the switch on httpCall (GET, PATCH ...)
     * 5) Only if it PATCH, PUT or POST add the body
     */
    enum WalletAPI: HTTPCallEndpoint {
        static let customerUUID = "00f9014f-8667-4cb1-87d5-d00e231190a8"

        static var jsonEncoder: JSONEncoder {
            return WayAppPay.jsonEncoder
        }
        
        static var jsonDecoder: JSONDecoder {
            return WayAppPay.jsonDecoder
        }
        
        typealias Email = String
        typealias PIN = String
        typealias PAN = String
        typealias Day = String

        public enum ResponseError {
             case INVALID_SERVER_DATA, MALFORMED_URL, NETWORK_UNAVAILABLE, INVALID_JSON, FORBIDDEN, NOT_FOUND, INTERNAL_ERROR
         }

        enum Result<T: Decodable, U> where U: Swift.Error {
            case success(Response<T>?)
            case failure(U)
        }
        
        static func reportError<T: Decodable>(_ response: Response<T>) {
            WayAppUtils.Log.message("Code=\(response.code ?? 0) , Status=\(response.status ?? "no status"), moreInfo=\(response.moreInfo ?? "no more info")")
        }
        
        static func errorFromResponse<T: Decodable>(_ response: Response<T>) -> Swift.Error {
            return NSError(domain: "WayAppPay.API", code: response.code ?? 0, userInfo:
                ["moreInfo": response.moreInfo ?? "no moreInfo",
                 "status" : response.status ?? "no status",
                 "description": "no description"])
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
        
        case postCheckin(String)
        case getCheckins(String)

        private var path: String {
            switch self {
            case .postCheckin(let token): return "/customers/\(WalletAPI.customerUUID)/cards/\(token)/checkins/"
            case .getCheckins(let token): return "/customers/\(WalletAPI.customerUUID)/cards/\(token)/checkins/"
            }
        }
        
        private var signature: String {
            switch self {
                case .postCheckin(let token): return WalletAPI.customerUUID + "/" + token
                case .getCheckins(let token): return WalletAPI.customerUUID + "/" + token
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
            // Need this function for future support of distinct APIs
            httpCall(type: decodingType, completionHandler: result)
        }
        

        private func httpCall<T: Decodable>(type decodingType: T.Type, completionHandler result: @escaping (Result<T, HTTPCall.Error>) -> Void) {
            switch self {
            case .postCheckin:
                // Response with data
                HTTPCall.POST(self).task(type: Response<T>.self) { response, error in
                    if let error = error {
                        result(.failure(error))
                    } else if let response = response as? Response<T> {
                        result(.success(response))
                    }
                }
            case .getCheckins:
                HTTPCall.GET(self).task(type: Response<T>.self) { response, error in
                    if let error = error {
                        result(.failure(error))
                    } else if let response = response as? Response<T> {
                        result(.success(response))
                    }
                }
            }
        }

        var url: URL? {
            let timestamp = Date().timeIntervalSince1970
            let signatureTimestamped = signature.isEmpty ? signature.appending(String(timestamp)) : signature.appending("/" + String(timestamp))
            let baseURL = OperationalEnvironment.walletAPIBaseURL + path + String(timestamp) + "/"
            return URL(string: baseURL + OperationalEnvironment.walletPublicKey + "/" + signatureTimestamped.digest(algorithm: .SHA256, key: OperationalEnvironment.walletPrivateKey))
        }
                
        var body: (String, Data)? {
            switch self {
            case .postCheckin:
                var parts: [HTTPCall.BodyPart]?
                let part = HTTPCall.BodyPart.JSON(name: "checkin", json: "{\"checkinInfo\":{\"mensaje1\":\"Hola Alejo\", \"mensaje2\":\"Hola Sil\"}}")
                parts = [part]
                if let parts = parts {
                    let multipart = HTTPCall.BodyPart.multipart(parts)
                    return (multipart.contentType, multipart.data)
                }
                return nil
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
