//
//  ShoppingCartRowView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/6/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct ShoppingCartRowView: View {
    var item: WayAppPay.ShoppingCartItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if item.isAmount {
                Image(systemName: "number.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: WayAppPay.UI.shoppingCartRowImageSize, height: WayAppPay.UI.shoppingCartRowImageSize)
            } else {
                ImageView(withURL: item.product.image, size: WayAppPay.UI.shoppingCartRowImageSize)
            }
            Text("\(item.cartItem.quantity)").fontWeight(.bold)
            Text(verbatim: item.isAmount ?
                item.product.description == nil ? item.product.name ?? WayAppPay.Product.defaultName : item.product.description!
                :
                item.product.name ?? WayAppPay.Product.defaultName)
            Spacer()
            Text("\(WayAppPay.priceFormatter(item.cartItem.price))")
        }
        .contextMenu {
            Button("Add one ➕") {
                self.addOne(self.item)
            }
            Button("Remove one ➖") {
                self.removeOne(self.item)
            }
            Button("Remove all 🗑") {
                self.removeAll(self.item)
            }
        }
    }
    
    private func removeOne(_ item: WayAppPay.ShoppingCartItem) {
        WayAppPay.session.shoppingCart.removeProduct(item.product)
    }
    
    private func addOne(_ item: WayAppPay.ShoppingCartItem) {
        WayAppPay.session.shoppingCart.addProduct(item.product)
    }
    
    private func removeAll(_ item: WayAppPay.ShoppingCartItem) {
        WayAppPay.session.shoppingCart.removeAllProduct(item.product)
    }
}

struct ShoppingCartRowView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingCartRowView(item: WayAppPay.ShoppingCartItem(product: WayAppPay.Product(name: "no name", price: 100)))
    }
}
