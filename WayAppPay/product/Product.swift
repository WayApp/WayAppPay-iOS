//
//  Product.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import UIKit

extension WayAppPay {
    
    struct Product: Codable, Identifiable, ContainerProtocol {
        
        static let defaultImageName = "questionmark.square"
        static let defaultName = "missing name"

        var productUUID: String
        var merchantUUID: String?
        var name: String?
        var description: String?
        var iva: Double?
        var price: Int?
        var image: String?
        var barcode: String?
        var keywords: [String]?
        var creationDate: Date?
        var lastUpdateDate: Date?
        
        // Protocols
        var id: String {
            return productUUID
        }

        var containerID: String {
            return productUUID
        }

        init(name: String, description: String = String(), price: Int) {
            self.productUUID = UUID().uuidString
            self.merchantUUID = WayAppPay.session.merchantUUID
            self.name = name
            self.description = description
            self.iva = 0
            self.price = price
        }
        
        static func loadForMerchant(_ merchantUUID: String) {
            WayAppPay.API.getProducts(merchantUUID).fetch(type: [Product].self) { response in
                if case .success(let response?) = response {
                    if let products = response.result {
                        DispatchQueue.main.async {
                            session.products.setTo(products)
                        }
                    } else {
                        WayAppPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }
        
        static func add(_ product: Product) {
            guard let merchantUUID = session.merchantUUID else {
                WayAppUtils.Log.message("missing Session.merchantUUID")
                return
            }
            WayAppPay.API.addProduct(merchantUUID, product, nil).fetch(type: [WayAppPay.Product].self) { response in
                if case .success(let response?) = response {
                    if let products = response.result,
                        let product = products.first {
                        session.products.add(product)
                    } else {
                        WayAppPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }

        private func composeIntPriceFromString(_ price: String) -> Int {
            var result: Int = 0
            let splitIn2 = price.components(separatedBy: .punctuationCharacters)
            if !splitIn2.isEmpty,
                let whole = Int(splitIn2[0]) {
                result = whole * 100
            }
            if splitIn2.count == 2,
                let decimals = Int(splitIn2[1].prefix(2)) {
                result += decimals
            }
            return result
        }
        
        func update(name: String, price: String, image: UIImage?, completion: @escaping (Error?) -> Void) {
            guard let merchantUUID = session.merchantUUID else {
                WayAppUtils.Log.message("missing Session.merchantUUID")
                return
            }
            var newProduct = self
            
            newProduct.name = name.isEmpty ? self.name : name
            newProduct.price = price.isEmpty ? self.price : composeIntPriceFromString(price)
            
            WayAppPay.API.updateProduct(merchantUUID, newProduct, image).fetch(type: [WayAppPay.Product].self) { response in
                if case .success(let response?) = response {
                    if let products = response.result,
                        let product = products.first {
                        DispatchQueue.main.async {
                            session.products[product.containerID] = product
                        }
                        completion(nil)
                    } else {
                        completion(WayAppPay.API.errorFromResponse(response))
                        WayAppPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    completion(error)
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }
        
        func delete() {
            guard let merchantUUID = session.merchantUUID else {
                WayAppUtils.Log.message("missing Session.merchantUUID")
                return
            }
            WayAppPay.API.deleteProduct(merchantUUID, self.productUUID).fetch(type: String.self) { response in
                if case .success(_) = response {
                    session.products.remove(self)
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }
        
    }
}
