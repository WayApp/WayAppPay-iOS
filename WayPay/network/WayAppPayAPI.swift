//
//  API.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import SwiftUI

extension WayPay {
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
            return WayPay.jsonEncoder
        }
        
        static var jsonDecoder: JSONDecoder {
            return WayPay.jsonDecoder
        }
        
        typealias Email = String
        typealias PIN = String
        typealias PAN = String
        typealias Day = String
        
        public enum ResponseError: Swift.Error {
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
            
            func debugOutput() -> String {
                return "Status: \(status ?? "No status"), Code: \(code ?? Int.zero), moreInfo: \(moreInfo ?? "No moreInfo")"
            }
        }
        
        // Account
        case registrationAccount(Registration) // POST
        case getAccount(Email, PIN) // GET
        case forgotPIN(ChangePIN) // POST
        case changePIN(ChangePIN) // POST
        case deleteAccount(String) // DELETE
        case checkin(PaymentTransaction) // POST
        // Merchant
        case getMerchants(String) // GET
        case getMerchantDetail(String) // GET
        case getMerchantAccounts(String) // GET
        case getMerchantAccountDetail(String, String) // GET
        case deleteMerchant(String) // GET
        // Product
        case getProducts(String) // GET
        case addProduct(String, Product, UIImage?) // POST
        case updateProduct(String, Product, UIImage?) // PATCH
        case deleteProduct(String, String) // DELETE
        case getProductDetail(String, String) // GET
        // Card
        case getCards(String) // GET
        case getCardDetail(String, PAN) // GET
        case deleteCard(String, PAN) // DELETE
        case getCardTransactions(String, PAN) // GET
        case getTransactionPayer(String, String, String) // GET
        case walletPayment(String, String, PaymentTransaction) // POST
        case createCard(String, Card) // POST
        case editCard(String, Card) // PATCH
        case refundTransaction(String, String, String, PaymentTransaction) // POST
        case topup(PaymentTransaction) // POST
        //Report
        case getTransaction(String, String, String) // GET
        case getMonthReportID(String, String, String) // GET
        case account(Account) // POST
        case editAccount(Account, UIImage?) // PATCH
        case sendEmail(String, String, SendEmail) // POST
        case getMerchantAccountTransactions(String, String) // GET
        case getMerchantAccountTransactionsForDay(String, String, Day) // GET
        case getMerchantAccountTransactionsByDates(String, String, Day, Day) // GET
        case getTransactionsForConsumerByDate(String, String, Day, Day) // GET
        case getSEPA(Day, Day, String, String) // GET
        // Issuers
        case getIssuers // GET
        case getIssuerTransactions(String, Day, Day) // GET
        case expireIssuerCards(String) // GET
        // Banks
        case getBanks(String) // GET
        case getConsentDetail(String) // GET
        case getConsent(String, AfterBanks.ConsentRequest) // POST
        // Campaign
        case createPointCampaign(Point)
        case createStampCampaign(Stamp)
        case updatePointCampaign(Point)
        case updateStampCampaign(Stamp)
        case getRewards(PaymentTransaction) // POST
        case toggleCampaignState(String, String, Campaign.Format)
        case getCampaigns(String, String?, Campaign.Format) // GET
        case getCampaign(String, String, Campaign.Format) // GET
        case deleteCampaign(String, String, Campaign.Format) // DELETE
        case rewardCampaigns(PaymentTransaction, Array<String>) // POST
        case rewardCampaign(PaymentTransaction, Campaign) // POST
        case redeemCampaigns(PaymentTransaction, Array<String>) // POST

        private var path: String {
            switch self {
            // Account
            case .registrationAccount: return "/accounts/registrations/"
            case .getAccount(let email, let hashedPIN): return "/accounts/\(email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)/\(hashedPIN)/"
            case .forgotPIN: return "/accounts/forgots/"
            case .changePIN: return "/accounts/passwords/"
            case .deleteAccount(let uuid): return "/accounts/\(uuid)/"
            case .checkin: return "/accounts/checkins/"
            // Merchants
            case .getMerchants(let accountUUID): return "/accounts/\(accountUUID)/merchants/"
            case .getMerchantDetail(let merchantUUID): return "/merchants/\(merchantUUID)/"
            case .getMerchantAccounts(let merchantUUID): return "/merchants/\(merchantUUID)/accounts/"
            case .getMerchantAccountDetail(let merchantUUID, let accountUUID): return "/merchants/\(merchantUUID)/accounts/\(accountUUID)/"
            case .deleteMerchant(let merchantUUID): return "/merchants/\(merchantUUID)/"
            // Products
            case .getProducts(let merchantUUID): return "/merchants/\(merchantUUID)/products/"
            case .addProduct(let merchantUUID, _, _): return "/merchants/\(merchantUUID)/products/"
            case .updateProduct(let merchantUUID, let product, _): return "/merchants/\(merchantUUID)/products/\(product.productUUID)/"
            case .deleteProduct(let merchantUUID, let productUUID): return "/merchants/\(merchantUUID)/products/\(productUUID)/"
            case .getProductDetail(let merchantUUID, let productUUID): return "/merchants/\(merchantUUID)/products/\(productUUID)/"
            // Cards
            case .getCards(let accountUUID): return "/accounts/\(accountUUID)/cards/"
            case .getCardDetail(let accountUUID, let pan): return "/accounts/\(accountUUID)/cards/\(pan)/"
            case .deleteCard(let accountUUID, let pan): return "/accounts/\(accountUUID)/cards/\(pan)/"
            case .getCardTransactions(let accountUUID, let pan): return "/accounts/\(accountUUID)/cards/\(pan)/transactions/"
            case .createCard(let accountUUID, _): return "/accounts/\(accountUUID)/cards/"
            case .editCard(let accountUUID, let card): return "/accounts/\(accountUUID)/cards/\(card.pan)/"
            case .topup: return "/topups/"
            // Transactions
            case .getTransactionPayer(let accountUUID, let merchantUUID, let transactionUUID): return "/merchants/\(merchantUUID)/accounts/\(accountUUID)/transactions/\(transactionUUID)/"
            case .walletPayment(let merchantUUID, let accountUUID, _): return "/merchants/\(merchantUUID)/accounts/\(accountUUID)/wallets/"
            case .getMonthReportID(let merchantUUID, let accountUUID, let reportID): return "/merchants/\(merchantUUID)/accounts/\(accountUUID)/reports/\(reportID)/"
            case .getTransaction(let merchantUUID, let accountUUID, let transactionUUID): return "/merchants/\(merchantUUID)/accounts/\(accountUUID)/transactions/\(transactionUUID)/"
            case .refundTransaction(let merchantUUID, let accountUUID, let transactionUUID, _): return "/merchants/\(merchantUUID)/accounts/\(accountUUID)/transactions/\(transactionUUID)/refunds/"
            case .getMerchantAccountTransactions(let merchantUUID, let accountUUID): return "/merchants/\(merchantUUID)/accounts/\(accountUUID)/transactions/"
            case .getMerchantAccountTransactionsForDay(let merchantUUID, let accountUUID, let day): return "/merchants/\(merchantUUID)/accounts/\(accountUUID)/transactions/dates/\(day)/"
            case .getMerchantAccountTransactionsByDates(let merchantUUID, let accountUUID, _, _): return "/merchants/\(merchantUUID)/accounts/\(accountUUID)/transactions/"
            case .getTransactionsForConsumerByDate(let merchantUUID, let accountUUID, _, _): return "/merchants/\(merchantUUID)/consumers/\(accountUUID)/transactions/"
            case .getSEPA( _, _, _, _): return "/merchants/newSEPAs/"
            case .sendEmail(let merchantUUID, let transactionUUID, _): return "/merchants/\(merchantUUID)/transactions/\(transactionUUID)/emails/"
            // Issuers
            case .getIssuers: return "/issuers/"
            case .getIssuerTransactions(let issuerUUID, _, _): return "/issuers/\(issuerUUID)/transactions/"
            case .expireIssuerCards(let issuerUUID): return "/issuers/\(issuerUUID)/expires/"
            // Banks
            case .getBanks: return "/banks/lists/"
            case .getConsentDetail(let consentID): return "/accounts/consents/\(consentID)/"
            case .getConsent(let accountUUID, _): return "/accounts/\(accountUUID)/consents/"
            // Campaign
            case .createPointCampaign: return "/campaigns/"
            case .createStampCampaign: return "/campaigns/"
            case .updatePointCampaign: return "/campaigns/"
            case .updateStampCampaign: return "/campaigns/"
            case .getRewards( _): return "/campaigns/rewards/gets/"
            case .getCampaigns: return "/campaigns/"
            case .toggleCampaignState(let campaignID, let sponsorUUID, _): return "/campaigns/\(campaignID)/sponsors/\(sponsorUUID)/toggles/"
            case .getCampaign(let campaignID, let sponsorUUID, _): return "/campaigns/\(campaignID)/sponsors/\(sponsorUUID)/"
            case .deleteCampaign(let campaignID, let sponsorUUID, _): return "/campaigns/\(campaignID)/sponsors/\(sponsorUUID)/"
            case .rewardCampaigns( _, _): return "/campaigns/rewards/"
            case .rewardCampaign( _, _): return "/campaigns/rewards/"
            case .redeemCampaigns( _, _): return "/campaigns/redeems/"
            // TRASH
            case .account: return "/accounts/"
            case .editAccount: return "/accounts/\(WayPay.session.accountUUID!)/"
            }
        }
        
        private var signature: String {
            switch self {
            // Account
            case .registrationAccount: return ""
            case .getAccount(let email, let hashedPIN): return email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)! + "/" + hashedPIN
            case .forgotPIN, .changePIN, .checkin: return ""
            case .deleteAccount(let accountUUID): return accountUUID
            // Merchant
            case .getMerchants(let accountUUID): return accountUUID
            case .getMerchantDetail(let merchantUUID): return merchantUUID
            case .getMerchantAccounts(let merchantUUID): return merchantUUID
            case .getMerchantAccountDetail(let merchantUUID, let accountUUID): return merchantUUID + "/" + accountUUID
            case .deleteMerchant(let merchantUUID): return merchantUUID
            // Product
            case .getProducts(let merchantUUID): return merchantUUID
            case .addProduct(let merchantUUID, _, _): return merchantUUID
            case .deleteProduct(let merchantUUID, let productUUID): return merchantUUID + "/" + productUUID
            case .getProductDetail(let merchantUUID, let productUUID): return merchantUUID + "/" + productUUID
            case .updateProduct(let merchantUUID, let product, _): return merchantUUID + "/" + product.productUUID
            // Card
            case .getCards(let accountUUID): return accountUUID
            case .getCardDetail(let accountUUID, let pan): return accountUUID + "/" + pan
            case .deleteCard(let accountUUID, let pan): return accountUUID + "/" + pan
            case .createCard(let accountUUID, _): return accountUUID
            case .editCard(let accountUUID, let card): return accountUUID + "/" + card.pan
            case .topup: return ""
            // PaymentTransaction
            case .getCardTransactions(let accountUUID, let pan): return accountUUID + "/" + pan
            case .getTransactionPayer(let accountUUID, let merchantUUID, let transactionUUID): return accountUUID + "/" + merchantUUID + "/" + transactionUUID
            case .walletPayment(let merchantUUID, let accountUUID, _): return merchantUUID + "/" + accountUUID
            case .getMonthReportID(let merchantUUID, let accountUUID, let reportID): return merchantUUID + "/" + accountUUID + "/" + reportID
            case .getTransaction(let merchantUUID, let accountUUID, let transactionUUID): return merchantUUID + "/" + accountUUID + "/" + transactionUUID
            case .refundTransaction(let merchantUUID, let accountUUID, let transactionUUID, _): return merchantUUID + "/" + accountUUID + "/" + transactionUUID
            case .getMerchantAccountTransactions(let merchantUUID, let accountUUID): return merchantUUID + "/" + accountUUID
            case .getMerchantAccountTransactionsForDay(let merchantUUID, let accountUUID, let day): return merchantUUID + "/" + accountUUID + "/" + day
            case .getMerchantAccountTransactionsByDates(let merchantUUID, let accountUUID, _, _): return merchantUUID + "/" + accountUUID
            case .getTransactionsForConsumerByDate(let merchantUUID, let accountUUID, _, _): return merchantUUID + "/" + accountUUID
            case .getSEPA: return ""
            case .sendEmail(let merchantUUID, let transactionUUID, _): return merchantUUID + "/" + transactionUUID
            // Issuers
            case .getIssuers: return ""
            case .getIssuerTransactions(let issuerUUID, _, _): return issuerUUID
            case .expireIssuerCards(let issuerUUID): return issuerUUID
            // Banks
            case .getBanks: return ""
            case .getConsentDetail(let consentId): return consentId
            case .getConsent(let accountUUID, _): return accountUUID
            // Campaign
            case .createPointCampaign: return ""
            case .createStampCampaign: return ""
            case .updatePointCampaign: return ""
            case .updateStampCampaign: return ""
            case .getRewards: return ""
            case .toggleCampaignState(let campaignID, let sponsorUUID, _): return campaignID + "/" + sponsorUUID
            case .getCampaigns: return ""
            case .getCampaign(let campaignID, let sponsorUUID, _): return campaignID + "/" + sponsorUUID
            case .deleteCampaign(let campaignID, let sponsorUUID, _): return campaignID + "/" + sponsorUUID
            case .rewardCampaigns: return ""
            case .rewardCampaign: return ""
            case .redeemCampaigns: return ""
            default: return ""
            }
        }
        
        func fetch<T: Decodable>(type decodingType: T.Type, completionHandler result: @escaping (Result<T, HTTPCall.Error>) -> Void) {
            // Need this function for future support of distinct APIs
            httpCall(type: decodingType, completionHandler: result)
        }

        private func httpCall<T: Decodable>(type decodingType: T.Type, completionHandler result: @escaping (Result<T, HTTPCall.Error>) -> Void) {
            switch self {
            case .getAccount, .getConsentDetail, .getProducts, .getProductDetail,.getMerchants, .getCards, .getCardDetail, .getCardTransactions, .getMerchantDetail, .getMerchantAccounts, .getMerchantAccountDetail, .getMerchantAccountTransactions, .getTransactionPayer, .getMonthReportID, .getMerchantAccountTransactionsForDay, .getTransaction, .getIssuers, .getBanks, .getMerchantAccountTransactionsByDates, .getTransactionsForConsumerByDate, .getSEPA, .getIssuerTransactions, .getCampaigns, .getCampaign, .expireIssuerCards, .toggleCampaignState:
                HTTPCall.GET(self).task(type: Response<T>.self) { response, error in
                    if let error = error {
                        result(.failure(error))
                    } else if let response = response as? Response<T> {
                        result(.success(response))
                    }
                }
            case .addProduct, .account, .walletPayment, .changePIN, .forgotPIN, .checkin, .refundTransaction, .sendEmail, .createCard, .getConsent, .topup, .registrationAccount, .createPointCampaign, .createStampCampaign, .rewardCampaigns, .rewardCampaign, .redeemCampaigns, .getRewards:
                HTTPCall.POST(self).task(type: Response<T>.self) { response, error in
                    if let error = error {
                        result(.failure(error))
                    } else if let response = response as? Response<T> {
                        result(.success(response))
                    }
                }
            case .updatePointCampaign, .updateStampCampaign:
                HTTPCall.PUT(self).task(type: Response<T>.self) { response, error in
                    if let error = error {
                        result(.failure(error))
                    } else if let response = response as? Response<T> {
                        result(.success(response))
                    }
                }
            case .updateProduct, .editAccount, .editCard:
                HTTPCall.PATCH(self).task(type: Response<T>.self) { response, error in
                    if let error = error {
                        result(.failure(error))
                    } else if let response = response as? Response<T> {
                        result(.success(response))
                    }
                }
            case .deleteAccount, .deleteCard, .deleteProduct, .deleteMerchant, .deleteCampaign:
                HTTPCall.DELETE(self).task(type: Response<T>.self) { response, error in
                    if let error = error {
                        result(.failure(error))
                    } else if let response = response as? Response<T> {
                        result(.success(response))
                    }
                }
            }
        }
        
        var queryParameters: String {
            switch self {
            case .getBanks(let countryCode):
                return "?countryCode=\(countryCode)"
            case .getMerchantAccountTransactionsByDates( _, _, let initialDate, let finalDate), .getTransactionsForConsumerByDate( _, _, let initialDate, let finalDate):
                return "?initialDate=\(initialDate)&finalDate=\(finalDate)"
            case .getIssuerTransactions( _, let initialDate, let finalDate):
                return "?initialDate=\(initialDate)&finalDate=\(finalDate)"
            case .getSEPA(let initialDate, let finalDate, let fieldName, let fieldValue):
                return "?initialDate=\(initialDate)&finalDate=\(finalDate)&fieldName=\(fieldName)&fieldValue=\(fieldValue)"
            case .getCampaigns(let merchantUUID, let issuerUUID, let format):
                return issuerUUID != nil ?
                    "?merchantUUID=\(merchantUUID)&issuerUUID=\(issuerUUID!)&format=\(format.rawValue)" :
                    "?merchantUUID=\(merchantUUID)&format=\(format.rawValue)"
            case .toggleCampaignState(_, _, let format), .getCampaign(_, _, let format), .deleteCampaign(_, _, let format):
                return "?format=\(format.rawValue)"
            default:
                return ""
            }
        }

        var url: URL? {
            let timestamp = Date().timeIntervalSince1970
            let signatureTimestamped = signature.isEmpty ? signature.appending(String(timestamp)) : signature.appending("/" + String(timestamp))
            let baseURL = OperationalEnvironment.wayappPayAPIBaseURL + path + String(timestamp) + "/"
            return URL(string: baseURL + OperationalEnvironment.wayAppPayPublicKey + "/" + signatureTimestamped.digest(algorithm: .SHA256, key: OperationalEnvironment.wayAppPayPrivateKey) + queryParameters)
            // Parquesur STAGING
//            return URL(string: baseURL + "fd09220a-3a69-4dc5-afd9-19e0e6d1c747" + "/" + signatureTimestamped.digest(algorithm: .SHA256, key: "c739a79b-8f73-4b7d-aca2-adad51ffa9bd") + queryParameters)
            // Las Rozas STAGING
//            return URL(string: baseURL + "f9a9b822-867c-11eb-8dcd-0242ac130003" + "/" + signatureTimestamped.digest(algorithm: .SHA256, key: "dde980f4-867c-11eb-8dcd-0242ac130003") + queryParameters)
//             Las Rozas PRODUCTION
//                return URL(string: baseURL + "f96879eb-17a2-48de-8cee-3c2123bfe9b2" + "/" + signatureTimestamped.digest(algorithm: .SHA256, key: "cd03e6be-7cfe-48a9-924f-703556e12e84") + queryParameters)
        }
                
        var body: (String, Data)? {
            switch self {
            case .account(let account):
                if let part = HTTPCall.BodyPart(account, name: "account") {
                    return (part.contentType, part.data)
                }
                return nil
            case .refundTransaction(_, _, _, let transaction):
                if let part = HTTPCall.BodyPart(transaction, name: "transaction") {
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
            case .changePIN(let changePIN), .forgotPIN(let changePIN):
                if let part = HTTPCall.BodyPart(changePIN, name: "account") {
                    let multipart = HTTPCall.BodyPart.multipart([part])
                    return (multipart.contentType, multipart.data)
                }
                return nil
            case .registrationAccount(let registration):
                if let part = HTTPCall.BodyPart(registration, name: "registration") {
                    let multipart = HTTPCall.BodyPart.multipart([part])
                    return (multipart.contentType, multipart.data)
                }
                return nil
            case .sendEmail(_, _, let sendEmail):
                if let part = HTTPCall.BodyPart(sendEmail, name: "email") {
                    let multipart = HTTPCall.BodyPart.multipart([part])
                    return (multipart.contentType, multipart.data)
                }
                return nil
            case .createCard(_, let card), .editCard(_, let card):
                if let part = HTTPCall.BodyPart(card, name: "card") {
                    let multipart = HTTPCall.BodyPart.multipart([part])
                    return (multipart.contentType, multipart.data)
                }
                return nil
            case .getConsent(_, let consentRequest):
                if let part = HTTPCall.BodyPart(consentRequest, name: "consentRequest") {
                    let multipart = HTTPCall.BodyPart.multipart([part])
                    return (multipart.contentType, multipart.data)
                }
                return nil
            case .createPointCampaign(let campaign), .updatePointCampaign(let campaign):
                if let part = HTTPCall.BodyPart(campaign, name: "campaign") {
                    let multipart = HTTPCall.BodyPart.multipart([part])
                    return (multipart.contentType, multipart.data)
                }
                return nil
            case .createStampCampaign(let campaign), .updateStampCampaign(let campaign):
                if let part = HTTPCall.BodyPart(campaign, name: "campaign") {
                    let multipart = HTTPCall.BodyPart.multipart([part])
                    return (multipart.contentType, multipart.data)
                }
                return nil
            case .walletPayment(_, _, let transaction), .topup(let transaction), .checkin(let transaction):
                var parts: [HTTPCall.BodyPart]?
                if let part = HTTPCall.BodyPart(transaction, name: "transaction") {
                    parts = [part]
                }
                if let parts = parts {
                    let multipart = HTTPCall.BodyPart.multipart(parts)
                    return (multipart.contentType, multipart.data)
                }
                return nil
            case .rewardCampaigns(let transaction, let campaignIDs), .redeemCampaigns(let transaction, let campaignIDs):
                var parts: [HTTPCall.BodyPart]?
                if let part = HTTPCall.BodyPart(transaction, name: "transaction") {
                    parts = [part]
                    if let part = HTTPCall.BodyPart(campaignIDs, name: "campaigns") {
                        parts?.append(part)
                    }
                }
                if let parts = parts {
                    let multipart = HTTPCall.BodyPart.multipart(parts)
                    return (multipart.contentType, multipart.data)
                }
                return nil
            case .getRewards(let transaction):
                var parts: [HTTPCall.BodyPart]?
                if let part = HTTPCall.BodyPart(transaction, name: "transaction") {
                    parts = [part]
                }
                if let parts = parts {
                    let multipart = HTTPCall.BodyPart.multipart(parts)
                    return (multipart.contentType, multipart.data)
                }
                return nil
            case .rewardCampaign(let transaction, let campaign):
                var parts: [HTTPCall.BodyPart]?
                if let part = HTTPCall.BodyPart(transaction, name: "transaction") {
                    parts = [part]
                    if let part = HTTPCall.BodyPart(campaign, name: "campaign") {
                        parts?.append(part)
                    }
                }
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
            switch self {
            case .registrationAccount:
                // Parquesur
//                return ["User-Agent": "9062358b-c0b3-45ff-84db-b452c9ac1289"]
                // Las Rozas
                return ["User-Agent": "138e3a2d-7666-4ac8-a0e0-145953ce8cab"]
            default:
                return nil
            }
        }
        
        func isUnauthorizedStatusCode(_ code: Int) -> Bool {
            return code == 401 || code == 403
        }
    }
}
