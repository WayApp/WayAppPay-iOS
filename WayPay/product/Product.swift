//
//  Product.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import UIKit

extension WayPay {
    
    struct Product: Codable, Identifiable, ContainerProtocol {
        
        static let defaultImageName = "questionmark.square"
        static let defaultName = NSLocalizedString("name", comment: "Placeholder name for new product")

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

        init(merchantUUID: String, name: String, description: String = String(), price: Int) {
            self.productUUID = UUID().uuidString
            self.merchantUUID = merchantUUID
            self.name = name
            self.description = description
            self.iva = 0
            self.price = price
        }
        
        static func get(_ merchantUUID: String , completion: @escaping ([Product]?, Error?) -> Void) {
            WayPay.API.getProducts(merchantUUID).fetch(type: [Product].self) { response in
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

        static func add(merchantUUID: String, product: Product, image: UIImage?, completion: @escaping (Product?, Error?) -> Void)  {
            WayPay.API.addProduct(merchantUUID, product, image).fetch(type: [Product].self) { response in
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

        func update(name: String, price: String, image: UIImage?, completion: @escaping (Error?) -> Void) {
            guard let merchantUUID = session.merchantUUID else {
                WayAppUtils.Log.message("missing Session.merchantUUID")
                return
            }
            var newProduct = self
            
            newProduct.name = name.isEmpty ? self.name : name
            newProduct.price = price.isEmpty ? self.price : WayAppUtils.composeIntPriceFromString(price)
            
            WayPay.API.updateProduct(merchantUUID, newProduct, image).fetch(type: [WayPay.Product].self) { response in
                if case .success(let response?) = response {
                    if let products = response.result,
                        let product = products.first {
                        DispatchQueue.main.async {
                            session.products[product.id] = product
                        }
                        completion(nil)
                    } else {
                        completion(WayPay.API.errorFromResponse(response))
                        WayPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    completion(error)
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }
                
        static func delete(at offsets: IndexSet) {
            guard let merchantUUID = session.merchantUUID else {
                WayAppUtils.Log.message("missing Session.merchantUUID")
                return
            }
            for offset in offsets {
                WayPay.API.deleteProduct(merchantUUID, session.products[offset].productUUID).fetch(type: [String].self) { response in
                    if case .success(_) = response {
                        WayAppUtils.Log.message("DELETED SUCCESSFULLY")
                        DispatchQueue.main.async {
                            WayAppUtils.Log.message("Before total products: \(session.products.count)")
                            session.products.remove(session.products[offset])
                            WayAppUtils.Log.message("After total products: \(session.products.count)")
                        }
                    } else if case .failure(let error) = response {
                        WayAppUtils.Log.message(error.localizedDescription)
                    }
                }
            }
        }

        
    }
}
