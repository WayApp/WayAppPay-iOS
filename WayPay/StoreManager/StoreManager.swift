//
//  StoreManager.swift
//  WayPay
//
//  Created by Oscar Anzola on 17/9/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import Foundation
import StoreKit

extension SKProduct {
    
    var display: String {
        return """
            title: \(localizedTitle),\
            description: \(localizedDescription),\
            price: \(price),\
            locale: \(priceLocale.description)
        """
    }
}

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @Published var myProducts = [(skProduct: SKProduct, receiptValidationStatus: ReceiptValidationStatus)]()
    @Published var transactionState: SKPaymentTransactionState?
    @Published var inAppPurchaseReceipt: JSON?

    
    public enum ReceiptResponseKey: String {
        case status
        case receipt
        case latest_receipt
        case latest_receipt_info
    }

    public enum ReceiptInfoKey: String {
        case bundle_id
        case application_version
        case original_application_version
        case creation_date
        case expiration_date
        case in_app
        
        enum InApp: String {
            case quantity
            case product_id
            case transaction_id
            case original_transaction_id
            case purchase_date
            case original_purchase_date
            case expires_date
            case expires_date_ms
            case cancellation_date
            #if os(iOS) || os(tvOS)
            case app_item_id
            #endif
            case version_external_identifier
            case web_order_line_item_id
        }
    }

    var request: SKProductsRequest?
    
    enum ReceiptValidationStatus: CaseIterable {
        case UNKNOWN, VALID, INVALID
    }
    
    enum ProductID: CaseIterable {
        case ONE
        
        var id: String {
            switch self {
            case .ONE: return "com.waypay.IAP.LoyaltyTierOne"
            }
        }
        
        static var allIDs: [String] {
            return ProductID.allCases.map( {$0.id} )
        }
        
        static var autoRenewableSubscriptions: [ProductID] {
            return ProductID.allCases
        }
    }
    
    var isReceiptValidationReady: Bool {
        return inAppPurchaseReceipt != nil
    }
    
    func validateAutoReneawableSubscriptions() {
        let autoReneawableSubscriptions = ProductID.autoRenewableSubscriptions
        for productID in autoReneawableSubscriptions {
            for (index, myProduct) in myProducts.enumerated() {
                if productID.id == myProduct.0.productIdentifier {
                    if (isReceiptValidationReady) {
                        if checkAutoRenewableExpiration(productID: productID.id) != nil {
                            WayAppUtils.Log.message("Product receipt validation: VALID")
                            myProducts[index].1 = .VALID
                        } else {
                            WayAppUtils.Log.message("Product receipt validation: INVALID")
                            myProducts[index].1 = .VALID
                        }
                    } else {
                        WayAppUtils.Log.message("Product receipt validation: UNKNOWN")
                        myProducts[index].1 = .VALID
                    }
                    break
                }
            }
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for fetchedProduct in response.products {
            WayAppUtils.Log.message("fetchedProduct: \(fetchedProduct.display)")
            DispatchQueue.main.async { [self] in
                self.myProducts.append((fetchedProduct, .UNKNOWN))
            }
        }

        for invalidIdentifier in response.invalidProductIdentifiers {
            WayAppUtils.Log.message("Invalid identifiers found: \(invalidIdentifier)")
        }
    }
    
    func getProducts(productIDs: [String]) {
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        WayAppUtils.Log.message("Request did fail: \(error)")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        WayAppUtils.Log.message("updatedTransactions")
        for transaction in transactions {
            WayAppUtils.Log.message("transaction: \(transaction.debugDescription)")
            switch transaction.transactionState {
            case .purchasing:
                transactionState = .purchasing
            case .purchased:
                UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                transactionState = .purchased
            case .restored:
                UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                transactionState = .restored
            case .failed, .deferred:
                WayAppUtils.Log.message("Payment Queue Error: \(String(describing: transaction.error))")
                queue.finishTransaction(transaction)
                transactionState = .failed
            default:
                queue.finishTransaction(transaction)
            }
        }
    }
    
    func purchaseProduct(product: SKProduct) {
        WayAppUtils.Log.message("Start purchase product: \(product.localizedTitle)")
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            WayAppUtils.Log.message("User can't make payment.")
        }
    }

    func restoreProducts() {
        WayAppUtils.Log.message("Restoring products ...")
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func receiptValidation() {
        let receiptPath = Bundle.main.appStoreReceiptURL?.path
        if FileManager.default.fileExists(atPath: receiptPath!) {
            var receiptData:NSData?
            do{
                receiptData = try NSData(contentsOf: Bundle.main.appStoreReceiptURL!, options: NSData.ReadingOptions.alwaysMapped)
            }
            catch{
                WayAppUtils.Log.message("Receipt validation error: " + error.localizedDescription)
            }
            let base64encodedReceipt = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)
            let requestDictionary = ["receipt-data":base64encodedReceipt!,"password":OperationalEnvironment.inPurchaseSharedKey]
            guard JSONSerialization.isValidJSONObject(requestDictionary) else {
                WayAppUtils.Log.message("Receipt validation error: " + "requestDictionary is not valid JSON")
                return
            }
            do {
                let requestData = try JSONSerialization.data(withJSONObject: requestDictionary)
                let validationURLString = OperationalEnvironment.receiptValidationURL
                guard let validationURL = URL(string: validationURLString) else { print("the validation url could not be created, unlikely error"); return }
                let session = URLSession(configuration: URLSessionConfiguration.default)
                var request = URLRequest(url: validationURL)
                request.httpMethod = "POST"
                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
                session.uploadTask(with: request, from: requestData) { (data, response, error) in
                    if let data = data,
                       let inAppPurchaseReceipt = try? JSONSerialization.jsonObject(with: data) as? JSON {
//                        WayAppUtils.Log.message("Success. Receipt: \(inAppPurchaseReceipt)")
                        self.inAppPurchaseReceipt = inAppPurchaseReceipt
                    } else if let error = error {
                        WayAppUtils.Log.message("Receipt validation failed. Error: \(error.localizedDescription)")
                    }
                }.resume()
            } catch let error as NSError {
                WayAppUtils.Log.message("Receipt validation error: " + "json serialization failed with error: \(error)")
            }
        }
    }

}

extension StoreManager {
    func checkAutoRenewableExpiration(productID: String) -> Date? {
        guard let inAppPurchaseReceipt = inAppPurchaseReceipt else {
            return nil
        }
        WayAppUtils.Log.message("productID: \(productID)")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        var mostRecentDate = Date.distantPast
        
        guard let latestReceiptInfo = inAppPurchaseReceipt[ReceiptResponseKey.latest_receipt_info.rawValue] as? [JSON] else {
            WayAppUtils.Log.message("Could not find latest receipt info for validation in JSON reponse")
            return (nil)
        }
        for receipt in latestReceiptInfo {
            let receiptProductID = receipt[ReceiptInfoKey.InApp.product_id.rawValue] as? String
            if receiptProductID == productID,
                let receiptExpirationDate =  receipt[ReceiptInfoKey.InApp.expires_date.rawValue] as? String,
                let date = formatter.date(from: receiptExpirationDate) {
                if date > mostRecentDate {
                    mostRecentDate = date
                }
            }
        }
        return ((mostRecentDate == Date.distantPast) ? nil : mostRecentDate)
    }
}
