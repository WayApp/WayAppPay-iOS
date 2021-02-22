//
//  ShoppingCart.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/6/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    
    // Used in this format by API
    struct CartItem: Codable {
        var name: String?
        var price: Int // defined as Int in API
        var quantity: Int // defined as Int in API
    }

    // Adds image to the API version of the API for proper display
    struct ShoppingCartItem: Identifiable, ContainerProtocol {
        var cartItem: CartItem
        var product: Product
        var isAmount: Bool = false
        
        var id: String {
            return product.productUUID
        }
        
        var containerID: String {
            return product.productUUID
        }
        
        init(product: Product, isAmount: Bool = false) {
            self.product = product
            self.isAmount = isAmount
            self.cartItem = CartItem(name: product.name ?? Product.defaultName, price: product.price ?? 0, quantity: 1)
        }
    }
    
    struct ShoppingCart {
        var items = Container<ShoppingCartItem>()
        
        var count: Int {
            var total: Int = 0
            for item in items {
                total += item.cartItem.quantity
            }
            return total
        }
        
        var isEmpty: Bool {
            return items.isEmpty
        }
        
        var arrayOfCartItems: [CartItem] {
            var cartItems: [CartItem] = []
            for shoppingCartItem in items {
                cartItems.append(shoppingCartItem.cartItem)
            }
            return cartItems
        }
        
        mutating func addProduct(_ product: Product, isAmount: Bool = false) {
            if let index = items.index(forID: product.productUUID) {
                items[index].cartItem.quantity += 1
            } else {
                items.add(ShoppingCartItem(product: product, isAmount: isAmount))
            }
        }
        
        mutating func removeProduct(_ product: Product) {
            if let index = items.index(forID: product.productUUID) {
                items[index].cartItem.quantity -= 1
                // If the quantity reaches 0 the product needs to be removed from the shopping cart
                if items[index].cartItem.quantity == 0 {
                    items.remove(at: index)
                }
            }
        }
        
        mutating func removeAllProduct(_ product: Product) {
            if let index = items.index(forID: product.productUUID) {
                items.remove(at: index)
            }
        }
        
        mutating func empty() {
            items.empty()
        }

    }

}
